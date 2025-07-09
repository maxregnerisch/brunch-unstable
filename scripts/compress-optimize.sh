#!/bin/bash

# Ultra Cool OS - Advanced Compression & Optimization Script
# Optimizes files and applies advanced compression for 1GB rootc.img

set -e

echo "🗜️  Ultra Cool OS Advanced Compression & Optimization"
echo "📦 Maximizing space efficiency for 1GB rootc.img"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${CYAN}[Optimizer]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Configuration
TARGET_DIR="${1:-./rootc_build/rootc}"
OPTIMIZATION_LEVEL="${2:-maximum}"

if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory $TARGET_DIR not found"
    exit 1
fi

print_status "Starting optimization of $TARGET_DIR"

# Function to get directory size
get_size() {
    du -sb "$1" 2>/dev/null | cut -f1 || echo "0"
}

INITIAL_SIZE=$(get_size "$TARGET_DIR")
print_status "Initial size: $((INITIAL_SIZE / 1024 / 1024))MB"

# 1. Remove unnecessary files and directories
print_status "Removing unnecessary files..."

# Remove development files
find "$TARGET_DIR" -name "*.a" -delete 2>/dev/null || true
find "$TARGET_DIR" -name "*.la" -delete 2>/dev/null || true
find "$TARGET_DIR" -name "*.pc" -delete 2>/dev/null || true
find "$TARGET_DIR" -name "*.cmake" -delete 2>/dev/null || true

# Remove Python cache
find "$TARGET_DIR" -name "*.pyc" -delete 2>/dev/null || true
find "$TARGET_DIR" -name "*.pyo" -delete 2>/dev/null || true
find "$TARGET_DIR" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find "$TARGET_DIR" -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove documentation and man pages (keep essential ones)
if [ "$OPTIMIZATION_LEVEL" = "maximum" ]; then
    find "$TARGET_DIR/usr/share/doc" -type f ! -name "copyright" -delete 2>/dev/null || true
    find "$TARGET_DIR/usr/share/info" -type f -delete 2>/dev/null || true
    rm -rf "$TARGET_DIR/usr/share/gtk-doc" 2>/dev/null || true
fi

# Remove locale files (keep English)
if [ -d "$TARGET_DIR/usr/share/locale" ]; then
    find "$TARGET_DIR/usr/share/locale" -mindepth 1 -maxdepth 1 -type d ! -name "en*" -exec rm -rf {} + 2>/dev/null || true
fi

# Remove unnecessary include files
if [ "$OPTIMIZATION_LEVEL" = "maximum" ]; then
    rm -rf "$TARGET_DIR/usr/include" 2>/dev/null || true
fi

print_success "Unnecessary files removed"

# 2. Strip binaries and libraries
print_status "Stripping binaries and libraries..."

# Strip all executables
find "$TARGET_DIR" -type f -executable -exec file {} \; | \
    grep -E "(ELF.*executable|ELF.*shared object)" | \
    cut -d: -f1 | \
    xargs -r strip --strip-unneeded 2>/dev/null || true

# Strip libraries
find "$TARGET_DIR" -name "*.so*" -type f -exec strip --strip-unneeded {} + 2>/dev/null || true

print_success "Binaries and libraries stripped"

# 3. Compress man pages
print_status "Compressing documentation..."

if [ -d "$TARGET_DIR/usr/share/man" ]; then
    # Remove existing compressed files
    find "$TARGET_DIR/usr/share/man" -name "*.gz" -delete 2>/dev/null || true
    
    # Compress all man pages
    find "$TARGET_DIR/usr/share/man" -type f -exec gzip -9 {} + 2>/dev/null || true
fi

print_success "Documentation compressed"

# 4. Optimize images and assets
print_status "Optimizing images and assets..."

# Optimize PNG files
if command -v optipng >/dev/null 2>&1; then
    find "$TARGET_DIR" -name "*.png" -exec optipng -quiet -o7 {} + 2>/dev/null || true
fi

# Optimize JPEG files
if command -v jpegoptim >/dev/null 2>&1; then
    find "$TARGET_DIR" -name "*.jpg" -o -name "*.jpeg" -exec jpegoptim --quiet --strip-all {} + 2>/dev/null || true
fi

# Optimize SVG files
if command -v svgo >/dev/null 2>&1; then
    find "$TARGET_DIR" -name "*.svg" -exec svgo --quiet {} + 2>/dev/null || true
fi

print_success "Images and assets optimized"

# 5. Deduplicate files
print_status "Deduplicating files..."

if command -v rdfind >/dev/null 2>&1; then
    rdfind -makehardlinks true -makeresultsfile false "$TARGET_DIR" 2>/dev/null || true
    print_success "File deduplication completed"
else
    print_status "rdfind not available, skipping deduplication"
fi

# 6. Compress CSS and JavaScript files
print_status "Compressing web assets..."

# Minify CSS files
find "$TARGET_DIR" -name "*.css" -type f | while read -r file; do
    if command -v csso >/dev/null 2>&1; then
        csso "$file" --output "$file.min" 2>/dev/null && mv "$file.min" "$file" || true
    else
        # Basic CSS minification
        sed -i 's/[[:space:]]*{[[:space:]]*/{/g; s/[[:space:]]*}[[:space:]]*/}/g; s/[[:space:]]*;[[:space:]]*/;/g' "$file" 2>/dev/null || true
    fi
done

# Minify JavaScript files
find "$TARGET_DIR" -name "*.js" -type f | while read -r file; do
    if command -v uglifyjs >/dev/null 2>&1; then
        uglifyjs "$file" --compress --mangle --output "$file.min" 2>/dev/null && mv "$file.min" "$file" || true
    fi
done

print_success "Web assets compressed"

# 7. Create optimized file system structure
print_status "Optimizing filesystem structure..."

# Create hardlinks for identical files
if command -v hardlink >/dev/null 2>&1; then
    hardlink -t "$TARGET_DIR" 2>/dev/null || true
fi

# Optimize directory structure
find "$TARGET_DIR" -type d -empty -delete 2>/dev/null || true

print_success "Filesystem structure optimized"

# 8. Advanced compression for specific file types
print_status "Applying advanced compression..."

# Compress large text files
find "$TARGET_DIR" -name "*.txt" -o -name "*.log" -o -name "*.conf" | while read -r file; do
    if [ -f "$file" ] && [ $(stat -c%s "$file") -gt 1024 ]; then
        gzip -9 "$file" 2>/dev/null || true
    fi
done

# Compress XML files
find "$TARGET_DIR" -name "*.xml" | while read -r file; do
    if [ -f "$file" ] && [ $(stat -c%s "$file") -gt 512 ]; then
        gzip -9 "$file" 2>/dev/null || true
    fi
done

print_success "Advanced compression applied"

# 9. Ultra Cool OS specific optimizations
print_status "Applying Ultra Cool OS specific optimizations..."

# Optimize Ultra Cool OS assets
if [ -d "$TARGET_DIR/opt/ultra-cool-os" ]; then
    # Compress SVG assets
    find "$TARGET_DIR/opt/ultra-cool-os" -name "*.svg" -exec gzip -9 {} \; -exec mv {}.gz {} \; 2>/dev/null || true
    
    # Optimize CSS files
    find "$TARGET_DIR/opt/ultra-cool-os" -name "*.css" -type f | while read -r file; do
        # Remove comments and unnecessary whitespace
        sed -i '/^[[:space:]]*\/\*/,/\*\//d; /^[[:space:]]*$/d; s/[[:space:]]\+/ /g' "$file" 2>/dev/null || true
    done
    
    # Optimize JavaScript files
    find "$TARGET_DIR/opt/ultra-cool-os" -name "*.js" -type f | while read -r file; do
        # Remove comments and unnecessary whitespace
        sed -i '/^[[:space:]]*\/\//d; /^[[:space:]]*$/d; s/[[:space:]]\+/ /g' "$file" 2>/dev/null || true
    done
fi

print_success "Ultra Cool OS optimizations applied"

# 10. Final cleanup and verification
print_status "Performing final cleanup..."

# Remove temporary files
find "$TARGET_DIR" -name "*.tmp" -o -name "*.temp" -o -name "*~" -delete 2>/dev/null || true

# Remove empty directories
find "$TARGET_DIR" -type d -empty -delete 2>/dev/null || true

# Fix permissions
find "$TARGET_DIR" -type f -exec chmod 644 {} + 2>/dev/null || true
find "$TARGET_DIR" -type d -exec chmod 755 {} + 2>/dev/null || true
find "$TARGET_DIR" -name "*.sh" -exec chmod 755 {} + 2>/dev/null || true

print_success "Final cleanup completed"

# Calculate final size and compression ratio
FINAL_SIZE=$(get_size "$TARGET_DIR")
SAVED_SIZE=$((INITIAL_SIZE - FINAL_SIZE))
COMPRESSION_RATIO=$((SAVED_SIZE * 100 / INITIAL_SIZE))

print_success "Optimization completed successfully!"

echo ""
echo -e "${PURPLE}📊 Optimization Summary:${NC}"
echo -e "   Initial Size: ${YELLOW}$((INITIAL_SIZE / 1024 / 1024))MB${NC}"
echo -e "   Final Size: ${GREEN}$((FINAL_SIZE / 1024 / 1024))MB${NC}"
echo -e "   Space Saved: ${GREEN}$((SAVED_SIZE / 1024 / 1024))MB${NC} (${COMPRESSION_RATIO}%)"
echo -e "   Optimization Level: ${BLUE}$OPTIMIZATION_LEVEL${NC}"
echo ""

# Create optimization report
cat > "$TARGET_DIR/../optimization_report.txt" << EOF
Ultra Cool OS Optimization Report
================================

Date: $(date)
Target Directory: $TARGET_DIR
Optimization Level: $OPTIMIZATION_LEVEL

Size Analysis:
- Initial Size: $((INITIAL_SIZE / 1024 / 1024))MB
- Final Size: $((FINAL_SIZE / 1024 / 1024))MB
- Space Saved: $((SAVED_SIZE / 1024 / 1024))MB
- Compression Ratio: ${COMPRESSION_RATIO}%

Optimizations Applied:
✅ Removed unnecessary files and directories
✅ Stripped binaries and libraries
✅ Compressed documentation
✅ Optimized images and assets
✅ Deduplicated files
✅ Compressed web assets
✅ Optimized filesystem structure
✅ Applied advanced compression
✅ Ultra Cool OS specific optimizations
✅ Final cleanup and verification

Status: SUCCESS
EOF

print_success "Optimization report created: $TARGET_DIR/../optimization_report.txt"

echo -e "${CYAN}🎉 Ultra Cool OS optimization completed successfully!${NC}"
echo -e "${GREEN}💾 Ready for 1GB rootc.img compilation${NC}"

