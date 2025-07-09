#!/usr/bin/env bash

# Ultra Cool OS Builder
# macOS 26 + mrOS 2.0 + Glassy Samsung Style
# Build script for the ultimate modern operating system

set -e

echo "🚀 Building Ultra Cool OS - The Future of Operating Systems!"
echo "📱 macOS 26 + mrOS 2.0 + Samsung Glassy Style Fusion"
echo "✨ Ultra Modern • Glassy Effects • Peak Performance"
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
    echo -e "${CYAN}[Ultra Cool OS]${NC} $1"
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
    print_error "Please run with sudo for Ultra Cool OS compilation"
    exit 1
fi

# Set ultra-modern build environment
export ULTRA_COOL_OS_VERSION="1.0"
export MACOS_26_STYLE="enabled"
export MROS_2_INTEGRATION="enabled"
export SAMSUNG_GLASSY_EFFECTS="enabled"
export BUILD_TYPE="ultra-modern"

print_status "Initializing Ultra Cool OS build environment..."

# Create ultra-modern build directory
BUILD_DIR="./ultra_cool_os_build"
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

print_success "Build environment initialized"

# Set ultra-modern bootsplash
print_status "Configuring ultra-modern boot experience..."
export BRUNCH_BOOTSPLASH="ultra-cool-macos26-mros2-glassy"

if [ ! -d "bootsplashes/$BRUNCH_BOOTSPLASH" ]; then
    print_error "Ultra Cool OS bootsplash not found!"
    exit 1
fi

print_success "Ultra-modern bootsplash configured"

# Apply ultra-modern patches
print_status "Applying Ultra Cool OS enhancements..."

# Make our custom patches executable
chmod +x brunch-patches/85-ultra-cool-os-ui.sh
chmod +x brunch-patches/86-ultra-cool-os-performance.sh
chmod +x brunch-patches/87-ultra-cool-os-advanced.sh

# Make build scripts executable
chmod +x build_rootc_img.sh
chmod +x scripts/compress-optimize.sh
chmod +x scripts/rootc-packager.py

print_success "Ultra Cool OS patches and scripts prepared"

# Build kernels with ultra-modern optimizations
print_status "Building ultra-optimized kernels..."

if [ -f "./build_kernels.sh" ]; then
    print_status "Compiling kernels with Ultra Cool OS optimizations..."
    
    # Add ultra-modern kernel flags
    export KERNEL_CFLAGS="-O3 -march=native -mtune=native -fomit-frame-pointer"
    export KERNEL_CONFIG_ULTRA_COOL="y"
    
    ./build_kernels.sh
    
    if [ $? -eq 0 ]; then
        print_success "Ultra-optimized kernels compiled successfully"
    else
        print_error "Kernel compilation failed"
        exit 1
    fi
else
    print_warning "Kernel build script not found, using pre-built kernels"
fi

# Create ultra-modern system configuration
print_status "Configuring Ultra Cool OS system settings..."

cat > "$BUILD_DIR/ultra_cool_os_info.txt" << EOF
Ultra Cool OS v${ULTRA_COOL_OS_VERSION}
================================

🎨 Design Philosophy:
   • macOS 26 inspired elegance
   • mrOS 2.0 functionality
   • Samsung glassy aesthetics
   • Ultra-modern performance

🚀 Features:
   • Glassy translucent effects
   • Ultra-smooth animations
   • Modern typography (SF Pro Display)
   • Advanced GPU acceleration
   • Optimized memory management
   • Samsung-style visual elements
   • macOS-like responsiveness

🔧 Technical Specifications:
   • ChromeOS base with ultra-modern enhancements
   • Custom UI layer with glass effects
   • Performance-optimized kernel
   • Advanced thermal management
   • Modern audio processing
   • Optimized for any hardware

📱 Compatibility:
   • Supports all ChromeOS compatible hardware
   • Enhanced performance on modern systems
   • Optimized for touchscreen devices
   • Full keyboard and mouse support

Built on: $(date)
Build Type: Ultra Modern Edition
EOF

print_success "System configuration completed"

# Run the main Brunch build with our enhancements
print_status "Building Ultra Cool OS image..."

# Set ultra-modern build flags
export BRUNCH_BUILD_TYPE="ultra-cool"
export ENABLE_GLASSY_EFFECTS="true"
export ENABLE_MACOS_STYLE="true"
export ENABLE_MROS_INTEGRATION="true"

# Run the main build script
if [ -f "./build_brunch.sh" ]; then
    print_status "Starting Ultra Cool OS compilation..."
    
    # Pass the ChromeOS recovery image if provided
    if [ ! -z "$1" ] && [ "$1" != "skip" ]; then
        ./build_brunch.sh "$1"
    else
        ./build_brunch.sh skip
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Ultra Cool OS compiled successfully!"
    else
        print_error "Ultra Cool OS compilation failed"
        exit 1
    fi
else
    print_error "Main build script not found!"
    exit 1
fi

# Create ultra-modern release package
print_status "Packaging Ultra Cool OS release..."

RELEASE_DIR="./ultra_cool_os_release"
mkdir -p "$RELEASE_DIR"

# Copy build artifacts
if [ -d "./out" ]; then
    cp -r ./out/* "$RELEASE_DIR/"
fi

# Create installation guide
cat > "$RELEASE_DIR/INSTALLATION_GUIDE.md" << 'EOF'
# Ultra Cool OS Installation Guide

## 🚀 Welcome to Ultra Cool OS!

Ultra Cool OS combines the elegance of macOS 26, the functionality of mrOS 2.0, and the stunning glassy aesthetics of Samsung's modern design language.

## ✨ Features

- **Glassy Translucent Effects**: Beautiful blur and transparency effects throughout the UI
- **macOS 26 Inspired Design**: Clean, modern interface with smooth animations
- **mrOS 2.0 Integration**: Advanced functionality and performance optimizations
- **Samsung Style Elements**: Sleek, modern visual components
- **Universal Hardware Support**: Works on any ChromeOS compatible device

## 📋 Installation Steps

1. **Download Ultra Cool OS**: Get the latest release from the releases page
2. **Create Installation Media**: Use Rufus, Etcher, or dd to write to USB drive
3. **Boot from USB**: Boot your device from the Ultra Cool OS USB
4. **Install**: Follow the on-screen installation wizard
5. **Enjoy**: Experience the future of operating systems!

## 🔧 System Requirements

- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 32GB minimum, 64GB recommended
- **CPU**: Any x86_64 processor
- **GPU**: Intel, AMD, or NVIDIA (with proper drivers)

## 🎨 Customization

Ultra Cool OS comes with multiple themes and customization options:
- Light and dark modes
- Adjustable transparency levels
- Custom accent colors
- Multiple wallpaper collections

## 🆘 Support

For support and updates, visit our GitHub repository or community forums.

---

**Ultra Cool OS** - Where elegance meets performance! 🌟
EOF

# Create version info
cat > "$RELEASE_DIR/VERSION.txt" << EOF
Ultra Cool OS v${ULTRA_COOL_OS_VERSION}
Build Date: $(date)
Base: ChromeOS with Ultra Modern Enhancements
Features: macOS 26 + mrOS 2.0 + Samsung Glassy Style
Architecture: x86_64
Compatibility: Universal Hardware Support
EOF

# Build 1GB rootc.img if requested
if [ "$1" = "rootc" ] || [ "$2" = "rootc" ]; then
    print_status "Building 1GB rootc.img..."
    
    if [ -f "./build_rootc_img.sh" ]; then
        ./build_rootc_img.sh
        
        if [ $? -eq 0 ]; then
            print_success "1GB rootc.img built successfully!"
            
            # Copy rootc.img to release directory
            if [ -f "./out/rootc.img" ]; then
                cp ./out/rootc.img* "$RELEASE_DIR/" 2>/dev/null || true
                cp ./out/install_rootc.sh "$RELEASE_DIR/" 2>/dev/null || true
            fi
        else
            print_warning "rootc.img build failed, continuing with standard build"
        fi
    else
        print_warning "rootc.img builder not found, skipping"
    fi
fi

print_success "Ultra Cool OS release package created"

# Final build summary
echo ""
echo -e "${PURPLE}🎉 Ultra Cool OS Build Complete! 🎉${NC}"
echo ""
echo -e "${CYAN}📦 Build Summary:${NC}"
echo -e "   Version: ${GREEN}v${ULTRA_COOL_OS_VERSION}${NC}"
echo -e "   Style: ${BLUE}macOS 26 + mrOS 2.0 + Samsung Glassy${NC}"
echo -e "   Build Type: ${YELLOW}Ultra Modern Edition${NC}"
echo -e "   Output: ${GREEN}$RELEASE_DIR${NC}"
echo ""
echo -e "${GREEN}✨ Your ultra-cool operating system is ready!${NC}"
echo -e "${CYAN}🚀 Boot it up and experience the future!${NC}"
echo ""

# Create checksums for verification
print_status "Generating checksums..."
cd "$RELEASE_DIR"
find . -type f -exec sha256sum {} \; > SHA256SUMS
cd ..

print_success "Checksums generated"
print_success "Ultra Cool OS build process completed successfully!"

echo ""
echo -e "${PURPLE}Thank you for choosing Ultra Cool OS! 🌟${NC}"
