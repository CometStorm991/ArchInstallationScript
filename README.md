# Arch Installation Script
My personal Arch installation script to automate both installing and setting up Arch Linux.
## Requirements
Two removable drives.
## Usage
### Stage 1
- Burn an Arch Linux installation image to a removable drive. (Let's call it Drive 1.)
- Insert the removable drive into the computer on which Arch Linux will be installed.
- Copy the installation script files (this repository's contents) onto another removable drive (Drive 2).
- Insert this removable drive as well.
- Run `lsblk` to see available drives and locate the partition on Drive 2 that contains the installation script files. The partition will be in the format `/dev/___#` where `___` is the name of the disk and `#` is the partition number.
- Run the following commands, replacing `<Drive 2 Partition>` with the located partition. 
```
mkdir --mount <Drive 2 Partition> /root/Scripts/
cp Scripts/RunInstallation.sh /root/
chmod +x /root/RunInstallation.sh
/root/RunInstallation.sh
```
### Stage 2
- Run the following command.
```
/root/Files/ConfigurationRoot.sh
```
### Stage 3
- Run the following command. The computer will reboot multiple times. Repeat the command after every reboot until the shell throws an error (when the script has finished and deleted itself)
```
~/Files/ConfigurationUser.sh
```
### Failure
In the case that a stage fails and the script exits, it is sometimes possible to resume the installation after making the necessary changes.
- Stage 1: Not possible - restart the installation
- Stage 2: Run the command `~/Files/RunConfigurationRoot.sh`. This will reload the installation script files from Drive 2 (Drive 2 must be specified when prompted) revert all changes made by Stage 2, and start Stage 2.
- Stage 3: The file `~/Files/configUser.txt`may contain the following fields, all of which may be set to `true` or `false` in the format `<field>=true|false` (no space around the `=`):
	- `verifyMicrocode`
	- `aurHelper`
	-  `installZsh`
	- `setupZsh`
	- `installZshPlugins`
	- `setupXorg`
	- `setupScripts`
	- `setupI3`
	- `setupSound`
	- `setupNetworking`
	- `setupApplications`
	- `setupVirtualization`
	- `substituteElements`
	- `terminate`
	Each of these fields correspond to an action described in Stage 3 of the Stages section. Setting a field to `false` will mark its corresponding action as incomplete, and setting a field to `true` will mark its corresponding action as complete. Running the command `~/Files/ConfigurationUser.sh` will run incomplete actions in the order described in Stage 3 of the Stages section.
## Stages
There are three stages to the Arch installation.
### Stage 1: The installation
During this stage, disk partitioning and installing foundational packages will occur. The foundational packages include the base Linux system, network manager, DKMS, manpages, build tools, and various other essential utilities. Before the installation starts, the user will be able to select a preconfigured profile if available and a device name.
#### Input Clarification
- "Enter disk partition with installation files."
	- Enter a disk **partition** (not disk)
	- Example partitions:
		- `/dev/sda1` for SCSI or SATA drives
		- `/dev/nvme0n1p1` for NVMe drives
### Stage 2: The root configuration
During this stage, the sudoers file will be configured, and new users and their passwords will be made. All new users will be added to the sudoers file.
### Stage 3: The user configuration
During this stage, the user accounts made in Stage 2 will be configured. This stage must be repeated for each user account made in Stage 2. Several actions will run in the order shown (with their `userConfig.txt` fields shown):
- Test the internet connection
- Verify microcode updates (`verifyMicrocode`)
- Install yay, the AUR helper (`aurHelper`)
- Install Zsh (`installZsh`)
- Import Zsh configuration (`setupZsh`)
- Install Zsh plugins (`installZshPlugins`)
- \*Install and setup Xorg, the display server (`setupXorg`)
- \*Import user script templates (`setupScripts`)
- \*Install and configure I3wm, the window manager, and Polybar
- \*Install sound management packages (`setupSound`)
- Install and setup firewall and SSH (`setupNetworking`)
- Install and configure user applications (Firefox, Kitty, etc) (`setupApplications`)
- Install and setup virtualization (`setupVirtualization`)
- \*Edit user script templates to match the user configuration (`substituteElements`)
- Delete this script (`terminate`)
The actions marked with an asterisk (\*) can be configured with a profile to run additional tasks.
## Profiles
Profiles can be made to run additional setup that is specific to a device. For example, a laptop will need the `sof-firmware` package installed to run onboard audio while a VM may instead need the `spice-vdagent` package. A profile can be created by making a folder named with the profile name in the `Profiles` directory of the installation script files. Each profile *must* contain the following scripts (although the scripts may contain nothing if no additional installation or configuration is necessary.) Each script must complete its own roles, which are shown below.
- Stage 1
	- `SetupDisk.sh`: Partition, format, and mount a disk (This script cannot be empty as Arch cannot be installed without a properly partitioned and formatted disk)
- Stage 3
	- `SetupXorg.sh`: Install additional display server packages
	- `SetupScripts.sh`: Install and edit additional user scripts
	- `SetupI3.sh`: Make additional configurations to the window manager
	- `SetupSound.sh`: Setup additional sound functionality
	- `SubstituteElements.sh`: Define variables used to edit the user script templates (This script cannot be empty as user script templates cannot run correctly without proper edits)
## Notes
- Additional manual setup may be necessary after the installation script finishes. For example, SSH keys may need to be copied to other devices and SSH password authentication may need to be disabled.
- Many application configuration files come from my alternate GitHub account [ShadowStar019](https://github.com/ShadowStar019/).
- The `GenerateImages.sh` can be ran from an existing UNIX system to generate an ISO file with the installation script files inside of it. This can be useful for loading the installation script files to a VM. The script relies on the command `mkisofs` from the cdrtools project.
## Todo
- Install GHCup and Rustup in Stage 3
- Install IntelliJ IDEs in Stage 3
- Install QT libraries in Stage 3
