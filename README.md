# Installation of CUDA and Display Driver on Linux without disabling secure boot
Installing Nvidia driver securely on Linux using Machine Owner Key (MOK) without disabling Secure Boot

## Step 0: Install the Prerequisites

In RHEL-based distros, install:

```bash
dnf install libglvnd libglvnd-devel
```

```bash
dnf install kernel-devel-$(uname -r) # RHEL 8 and later
```

```bash
dnf install kernel-64k-devel-matched kernel-headers
```

```bash
dnf install mokutil openssl kernel-devel kernel-headers gcc make
```

```bash
dnf install gcc gcc-gfortran # GCC Compiler
```

## Step 1: Download CUDA Driver

Download from: https://developer.nvidia.com/cuda-downloads

> **Note:** CUDA v.13 also includes NVIDIA Display driver

## Step 2: Extract the CUDA Driver in One Location

Upon downloading the cuda*.run file:

1. Login as root
```bash
su -
mkdir Nv
./cuda_13.0.2_580.95.05_linux.run --extract=/Nv
```

Specify the location to extract, in this case the newly created directory.

## Step 3: Install the Display Driver Separately (Recommended When Secure Boot is Enabled)

### Step 3.1: Create Machine Owner Keys (MOK) Signing Keys and Store Securely as Root

```bash
mkdir -p /etc/ssl/private/custom-mok-keys
```

```bash
cd /etc/ssl/private/custom-mok-keys
```

```bash
openssl req -new -x509 -newkey rsa:2048 -keyout nvidia-driver.key -outform DER -out nvidia-driver.der -nodes -days 5500 -subj "/CN=My custom signing key for Nvidia driver/"
```

```bash
# Convert to PEM format
openssl x509 -in nvidia-driver.der -inform DER -out nvidia-driver.pem -outform PEM
```

### Step 3.2: Enroll the Key with MOK

```bash
mokutil --import nvidia-driver.der
```

You will be prompted to create a password. Use the same password during key enrollment.

Reboot to apply:
```bash
reboot
```

Upon reboot, you will be prompted to a blue screen to complete enrollment.

During boot:
1. System will enter MOK Management
2. Select "Enroll MOK"
3. Select "Continue"
4. Select "Yes"
5. Enter the password you created
6. Select "OK" and reboot

### Step 3.3: Verify

Upon enrollment after reboot, verify the enrollment:
```bash
mokutil --list-enrolled | grep "My custom signing key for Nvidia driver"
```

## Step 4: Install NVIDIA Display Driver

It is important to first install the display driver before installing the CUDA driver.

```bash
cd Nv/
```
```bash
./NVIDIA-Linux-x86_64-*.run --module-signing-secret-key=/etc/ssl/private/custom-mok-keys/nvidia-driver.key --module-signing-public-key=/etc/ssl/private/custom-mok-keys/nvidia-driver.pem
```

Review and accept the terms and follow through the steps. The driver will be installed successfully.

## Step 5: Install CUDA Driver

```bash
cd /
./cuda_13.0.2_580.95.05_linux.run
```

> **Important:** Uncheck install display driver and proceed.

The CUDA driver will be installed successfully.

Upon installation, manually add the PATH to the ~/.bashrc and refresh.

## Step 6: (Optional) Remove Private Key to Avoid Further MOK Signings

```bash
rm /etc/ssl/private/custom-mok-keys/nvidia-driver.key
```
