# Engineering Guide: Dual-Boot Hardware State Collisions & ACPI D3 Mitigation

## 1. Overview & Threat Model

In dual-boot environments sharing hardware between Windows 10/11 and Linux (Ubuntu 22.04 LTS), network adapters—particularly wireless PCI Express (PCIe) and USB network interface cards (NICs)—frequently exhibit erratic failure modes when booting into Linux immediately following a Windows session:

- **Symptom 1:** The wireless interface associates with the 802.11 AP and obtains an IP address, but stalls on all TCP/UDP transmission (`0 packets received`).
- **Symptom 2:** The Linux driver (`iwlwifi`, `rtw89`, `ath10k`, or `mt7921e`) logs firmware initialization timeouts or crash dumps in `dmesg`:
  ```
  iwlwifi 0000:02:00.0: Failed to run INIT ucode: -110
  iwlwifi 0000:02:00.0: Unable to initialize device.
  ```
- **Symptom 3:** The hardware interface is completely absent from `ip link` or `lspci` until a hard power cycle is performed.

---

## 2. Root Cause: Windows Fast Startup (Hybrid Shutdown)

### 2.1 The Hybrid Sleep Mechanism

Windows Fast Startup (introduced in Windows 8, enabled by default in Windows 10 and 11) modifies the standard OS shutdown sequence:

```
Standard ACPI Shutdown (S5 - Soft Off):
  Close User Apps → Stop User Services → Stop System Services →
  Unload Drivers → Flush Storage → Signal Hardware Power Off (S5)

Windows Fast Startup (Hybrid S4):
  Close User Apps → Save Kernel & Driver State to C:\hiberfil.sys →
  Put Hardware Controllers into Low-Power Sleep (ACPI D3hot / D3cold) →
  Cut Main Power without Hardware Reset
```

### 2.2 The Cross-OS State Collision

When Fast Startup executes:

1. **Firmware Retention:** Windows leaves the network controller's on-chip microcontroller running in a low-power, initialized state rather than resetting it to bare-metal power-on defaults.
2. **DMA & Register Locks:** Physical memory mappings and Direct Memory Access (DMA) registers configured by Windows driver stacks remain resident in the hardware's internal state machines.
3. **Linux Boot Phase:** When the machine powers on and GRUB boots Linux, the Linux kernel expects all hardware devices to be in a clean **ACPI D0 (Uninitialized Power-On)** state.
4. **Collision:** The Linux device driver attempts to upload firmware microcode into an adapter that is already executing conflicting microcode from the previous Windows driver session. The handshake fails, resulting in driver failure or silent packet drop.

---

## 3. Mitigation Procedures

### 3.1 Method A: PowerShell Administrator Command (Immediate)

To disable Windows Fast Startup system-wide from an administrative terminal:

```powershell
# Disable hibernation entirely (automatically disables Fast Startup and frees hiberfil.sys storage):
powercfg.exe /hibernate off

# Verify hibernation status:
powercfg.exe /a
# Expected: "The following sleep states are not available on this system: Hibernate"
```

### 3.2 Method B: Windows Control Panel GUI

If hibernation functionality is desired for laptops (suspend-to-disk) but Fast Startup must be isolated:

1. Open **Control Panel** (`control.exe`).
2. Navigate to **Hardware and Sound** → **Power Options**.
3. In the left sidebar, click **Choose what the power buttons do**.
4. Click **Change settings that are currently unavailable** (requires Administrator elevation).
5. Under **Shutdown settings**, locate **Turn on fast startup (recommended)**.
6. **Uncheck** the checkbox.
7. Click **Save changes**.

---

## 4. Linux Kernel Driver Power Management Tweaks

In addition to disabling Windows Fast Startup, wireless stability on dual-boot machines can be reinforced within Ubuntu:

### 4.1 Disable Wi-Fi Power Saving

Ubuntu's NetworkManager enables 802.11 power saving by default, which can cause frame drops on budget or USB-attached adapters:

```ini
# /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
[connection]
# Value 2 = Disable power saving (1 = default, 2 = disable, 3 = enable)
wifi.powersave = 2
```

Apply the configuration:

```bash
sudo systemctl restart NetworkManager
```

### 4.2 Module Parameter Tuning for Intel Wi-Fi (`iwlwifi`)

If utilizing Intel AX/AC wireless cards:

```ini
# /etc/modprobe.d/iwlwifi-stability.conf
# Disable aggressive power-saving sub-states
options iwlwifi power_save=0
options iwlwifi uapsd_disable=1
```

Reload the driver module:

```bash
sudo modprobe -r iwlmvm iwlwifi
sudo modprobe iwlwifi
```
