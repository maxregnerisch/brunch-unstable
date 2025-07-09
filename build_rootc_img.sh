#!/usr/bin/env bash

# Ultra Cool OS - 1GB rootc.img Builder
# Advanced compression and optimization system for Ultra Cool OS
# Creates a highly optimized 1GB root filesystem image

set -e

echo "🚀 Ultra Cool OS - 1GB rootc.img Builder"
echo "📦 Advanced Compression & Optimization System"
echo "✨ macOS 26 + mrOS 2.0 + Samsung Glassy Style"
echo ""

# Color codes for ultra-modern output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${CYAN}[rootc.img Builder]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if running as root
if [ $(whoami) != "root" ]; then
    print_error "Please run with sudo for rootc.img compilation"
    exit 1
fi

# Configuration
ROOTC_SIZE="1073741824"  # 1GB in bytes
ROOTC_SIZE_MB="1024"     # 1GB in MB
BUILD_DIR="./rootc_build"
OUTPUT_DIR="./out"
ROOTC_IMAGE="$OUTPUT_DIR/rootc.img"
COMPRESSION_LEVEL="9"    # Maximum compression

print_status "Initializing 1GB rootc.img build environment..."

# Create build directories
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

print_success "Build environment initialized"

# Check available space
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
REQUIRED_SPACE=$((ROOTC_SIZE_MB * 3))  # Need 3x space for build process

if [ $AVAILABLE_SPACE -lt $((REQUIRED_SPACE * 1024)) ]; then
    print_error "Insufficient disk space. Need ${REQUIRED_SPACE}MB, have ${AVAILABLE_SPACE}KB"
    exit 1
fi

print_success "Disk space check passed"

# Create optimized filesystem structure
print_status "Creating optimized filesystem structure..."

# Create base directory structure
mkdir -p "$BUILD_DIR/rootc"/{bin,sbin,lib,lib64,usr,var,etc,dev,proc,sys,tmp,home,opt,mnt,media,run,srv}
mkdir -p "$BUILD_DIR/rootc/usr"/{bin,sbin,lib,lib64,share,local,include}
mkdir -p "$BUILD_DIR/rootc/var"/{log,cache,tmp,lib,spool}
mkdir -p "$BUILD_DIR/rootc/etc"/{init.d,systemd,ultra-cool-os}
mkdir -p "$BUILD_DIR/rootc/opt/ultra-cool-os"

print_success "Base filesystem structure created"

# Copy essential Ultra Cool OS components
print_status "Installing Ultra Cool OS components..."

# Copy essential binaries (minimal set)
ESSENTIAL_BINS="bash sh ls cp mv rm mkdir rmdir cat echo grep sed awk chmod chown mount umount"
for bin in $ESSENTIAL_BINS; do
    if [ -f "/bin/$bin" ]; then
        cp "/bin/$bin" "$BUILD_DIR/rootc/bin/"
    elif [ -f "/usr/bin/$bin" ]; then
        cp "/usr/bin/$bin" "$BUILD_DIR/rootc/usr/bin/"
    fi
done

# Copy essential libraries with optimization
print_status "Optimizing and copying essential libraries..."

# Create library dependency resolver
cat > "$BUILD_DIR/resolve_deps.sh" << 'EOF'
#!/bin/bash
find_deps() {
    local binary="$1"
    local rootc_dir="$2"
    
    if [ ! -f "$binary" ]; then
        return
    fi
    
    # Get library dependencies
    ldd "$binary" 2>/dev/null | grep -E "^\s*/" | awk '{print $1}' | while read lib; do
        if [ -f "$lib" ] && [ ! -f "$rootc_dir/lib/$(basename $lib)" ] && [ ! -f "$rootc_dir/lib64/$(basename $lib)" ]; then
            # Determine target directory
            if [[ "$lib" == *"lib64"* ]]; then
                target_dir="$rootc_dir/lib64"
            else
                target_dir="$rootc_dir/lib"
            fi
            
            # Copy and strip library
            cp "$lib" "$target_dir/"
            strip "$target_dir/$(basename $lib)" 2>/dev/null || true
            echo "Copied: $(basename $lib)"
        fi
    done
}

# Process all binaries
for binary in "$2"/bin/* "$2"/usr/bin/* "$2"/sbin/* "$2"/usr/sbin/*; do
    if [ -f "$binary" ]; then
        find_deps "$binary" "$2"
    fi
done
EOF

chmod +x "$BUILD_DIR/resolve_deps.sh"
"$BUILD_DIR/resolve_deps.sh" "" "$BUILD_DIR/rootc"

print_success "Essential libraries optimized and installed"

# Install Ultra Cool OS specific components
print_status "Installing Ultra Cool OS advanced features..."

# Copy Ultra Cool OS patches and configurations
if [ -f "brunch-patches/87-ultra-cool-os-advanced.sh" ]; then
    cp "brunch-patches/87-ultra-cool-os-advanced.sh" "$BUILD_DIR/rootc/opt/ultra-cool-os/"
    chmod +x "$BUILD_DIR/rootc/opt/ultra-cool-os/87-ultra-cool-os-advanced.sh"
fi

# Copy UI framework
if [ -d "/opt/ultra-cool-os/ui-framework" ]; then
    cp -r "/opt/ultra-cool-os/ui-framework" "$BUILD_DIR/rootc/opt/ultra-cool-os/" 2>/dev/null || true
fi

# Copy configuration files
if [ -f "ultra_cool_os_config.json" ]; then
    cp "ultra_cool_os_config.json" "$BUILD_DIR/rootc/etc/ultra-cool-os/"
fi

# Create optimized bootsplash
if [ -d "bootsplashes/ultra-cool-macos26-mros2-glassy" ]; then
    mkdir -p "$BUILD_DIR/rootc/opt/ultra-cool-os/bootsplash"
    cp -r "bootsplashes/ultra-cool-macos26-mros2-glassy"/* "$BUILD_DIR/rootc/opt/ultra-cool-os/bootsplash/"
fi

print_success "Ultra Cool OS components installed"

# Create minimal init system
print_status "Creating optimized init system..."

cat > "$BUILD_DIR/rootc/sbin/init" << 'EOF'
#!/bin/bash
# Ultra Cool OS Minimal Init System

echo "🚀 Ultra Cool OS Starting..."

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp

# Apply Ultra Cool OS enhancements
if [ -f "/opt/ultra-cool-os/87-ultra-cool-os-advanced.sh" ]; then
    echo "✨ Loading Ultra Cool OS Advanced Features..."
    /opt/ultra-cool-os/87-ultra-cool-os-advanced.sh
fi

# Start main system
echo "🎯 Ultra Cool OS Ready!"
exec /bin/bash
EOF

chmod +x "$BUILD_DIR/rootc/sbin/init"

print_success "Optimized init system created"

# Create system configuration files
print_status "Creating optimized system configuration..."

# Create minimal fstab
cat > "$BUILD_DIR/rootc/etc/fstab" << 'EOF'
# Ultra Cool OS Optimized Filesystem Table
proc            /proc           proc    defaults                0 0
sysfs           /sys            sysfs   defaults                0 0
devtmpfs        /dev            devtmpfs defaults              0 0
tmpfs           /tmp            tmpfs   defaults,size=512M      0 0
tmpfs           /var/tmp        tmpfs   defaults,size=256M      0 0
EOF

# Create optimized system info
cat > "$BUILD_DIR/rootc/etc/os-release" << 'EOF'
NAME="Ultra Cool OS"
VERSION="1.0 (Glassy Fusion)"
ID=ultra-cool-os
ID_LIKE=chromeos
VERSION_ID="1.0"
PRETTY_NAME="Ultra Cool OS 1.0 (Glassy Fusion)"
ANSI_COLOR="0;34"
HOME_URL="https://github.com/maxregnerisch/brunch-unstable"
SUPPORT_URL="https://github.com/maxregnerisch/brunch-unstable/issues"
BUG_REPORT_URL="https://github.com/maxregnerisch/brunch-unstable/issues"
LOGO="ultra-cool-os"
EOF

# Create hostname
echo "ultra-cool-os" > "$BUILD_DIR/rootc/etc/hostname"

print_success "System configuration created"

# Optimize filesystem for size
print_status "Optimizing filesystem for maximum compression..."

# Remove unnecessary files
find "$BUILD_DIR/rootc" -name "*.a" -delete
find "$BUILD_DIR/rootc" -name "*.la" -delete
find "$BUILD_DIR/rootc" -name "*.pyc" -delete
find "$BUILD_DIR/rootc" -name "*.pyo" -delete
find "$BUILD_DIR/rootc" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Strip all binaries and libraries
print_status "Stripping binaries and libraries..."
find "$BUILD_DIR/rootc" -type f -executable -exec strip {} + 2>/dev/null || true
find "$BUILD_DIR/rootc" -name "*.so*" -exec strip {} + 2>/dev/null || true

# Compress man pages and documentation
find "$BUILD_DIR/rootc/usr/share/man" -name "*.gz" -delete 2>/dev/null || true
find "$BUILD_DIR/rootc/usr/share/man" -type f -exec gzip -9 {} + 2>/dev/null || true

print_success "Filesystem optimization complete"

# Calculate current size
CURRENT_SIZE=$(du -sb "$BUILD_DIR/rootc" | cut -f1)
print_status "Current filesystem size: $((CURRENT_SIZE / 1024 / 1024))MB"

# Create the 1GB image file
print_status "Creating 1GB image file..."

# Create sparse file
dd if=/dev/zero of="$ROOTC_IMAGE" bs=1M count=0 seek=$ROOTC_SIZE_MB status=progress

# Create filesystem with maximum compression
print_status "Creating optimized ext4 filesystem..."
mkfs.ext4 -F -m 1 -O ^has_journal,^ext_attr,^resize_inode,^dir_index "$ROOTC_IMAGE"

# Mount and populate
MOUNT_POINT="$BUILD_DIR/mount"
mkdir -p "$MOUNT_POINT"
mount -o loop "$ROOTC_IMAGE" "$MOUNT_POINT"

print_status "Copying optimized filesystem to image..."
cp -a "$BUILD_DIR/rootc"/* "$MOUNT_POINT/"

# Optimize filesystem on image
print_status "Final filesystem optimization..."
sync
e2fsck -f -y "$ROOTC_IMAGE" || true
resize2fs -M "$ROOTC_IMAGE"

umount "$MOUNT_POINT"

# Compress the image
print_status "Applying advanced compression..."
COMPRESSED_IMAGE="$OUTPUT_DIR/rootc.img.xz"
xz -${COMPRESSION_LEVEL}e -T 0 -c "$ROOTC_IMAGE" > "$COMPRESSED_IMAGE"

# Create checksums
print_status "Generating checksums..."
cd "$OUTPUT_DIR"
sha256sum rootc.img > rootc.img.sha256
sha256sum rootc.img.xz > rootc.img.xz.sha256
cd ..

# Final size report
FINAL_SIZE=$(stat -c%s "$ROOTC_IMAGE")
COMPRESSED_SIZE=$(stat -c%s "$COMPRESSED_IMAGE")
COMPRESSION_RATIO=$((COMPRESSED_SIZE * 100 / FINAL_SIZE))

print_success "1GB rootc.img compilation complete!"

echo ""
echo -e "${PURPLE}📊 Build Summary:${NC}"
echo -e "   Image Size: ${GREEN}$((FINAL_SIZE / 1024 / 1024))MB${NC}"
echo -e "   Compressed: ${GREEN}$((COMPRESSED_SIZE / 1024 / 1024))MB${NC} (${COMPRESSION_RATIO}% of original)"
echo -e "   Format: ${BLUE}ext4 with advanced optimization${NC}"
echo -e "   Features: ${YELLOW}macOS 26 + mrOS 2.0 + Samsung Glassy Style${NC}"
echo ""

# Create installation script
cat > "$OUTPUT_DIR/install_rootc.sh" << 'EOF'
#!/bin/bash
# Ultra Cool OS rootc.img Installation Script

echo "🚀 Ultra Cool OS rootc.img Installer"
echo "Installing 1GB optimized root filesystem..."

if [ ! -f "rootc.img.xz" ]; then
    echo "❌ rootc.img.xz not found!"
    exit 1
fi

# Verify checksum
if [ -f "rootc.img.xz.sha256" ]; then
    echo "🔍 Verifying checksum..."
    sha256sum -c rootc.img.xz.sha256 || exit 1
    echo "✅ Checksum verified"
fi

# Decompress
echo "📦 Decompressing rootc.img..."
xz -d rootc.img.xz

echo "✅ Ultra Cool OS rootc.img ready for use!"
echo "🎯 Features: macOS 26 + mrOS 2.0 + Samsung Glassy Style"
EOF

chmod +x "$OUTPUT_DIR/install_rootc.sh"

# Cleanup
rm -rf "$BUILD_DIR"

print_success "Ultra Cool OS 1GB rootc.img build process completed successfully!"

echo ""
echo -e "${CYAN}🎉 Your ultra-optimized 1GB rootc.img is ready!${NC}"
echo -e "${GREEN}📁 Location: $ROOTC_IMAGE${NC}"
echo -e "${GREEN}📦 Compressed: $COMPRESSED_IMAGE${NC}"
echo -e "${PURPLE}✨ Ready to boot the future of operating systems!${NC}"
echo ""

