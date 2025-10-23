dnf install libglvnd libglvnd-devel
dnf install kernel-devel-$(uname -r) # RHEL 8 and later
dnf install kernel-64k-devel-matched kernel-headers
dnf install mokutil openssl kernel-devel kernel-headers gcc make
dnf install gcc gcc-gfortran # GCC Compiler

# Extract the CUDA Driver in One Location

su -
mkdir Nv
./cuda_13.0.2_580.95.05_linux.run --extract=/Nv

# Create Machine Owner Keys (MOK) Signing Keys and Store Securely as Root

mkdir -p /etc/ssl/private/custom-mok-keys
cd /etc/ssl/private/custom-mok-keys
sudo openssl req -new -x509 -newkey rsa:4096 -keyout nvidia-driver.key -outform DER -out nvidia-driver.der -nodes -days 5500 -subj "/CN=My custom signing key for Nvidia driver/"
# Convert to PEM format
sudo openssl x509 -in nvidia-driver.der -inform DER -out nvidia-driver.pem -outform PEM


# Enroll the Key with MOK

mokutil --import nvidia-driver.der

reboot


# verify the enrollment

mokutil --list-enrolled | grep "My custom signing key for Nvidia driver"


# Install the Display Driver Separately 
# Recommended When Secure Boot is Enabled


cd Nv/
./NVIDIA-Linux-x86_64-*.run --module-signing-secret-key=/etc/ssl/private/custom-mok-keys/nvidia-driver.key --module-signing-public-key=/etc/ssl/private/custom-mok-keys/nvidia-driver.pem

#Install CUDA Driver cuda-*.run https://developer.nvidia.com/cuda-downloads

cd /
./cuda_13.0.2_580.95.05_linux.run



# Optional 

rm /etc/ssl/private/custom-mok-keys/nvidia-driver.key
