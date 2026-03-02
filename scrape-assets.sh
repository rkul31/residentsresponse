#!/bin/bash
set -euo pipefail

SITE_URL="https://www.residentsresponse.com"
OUTPUT_DIR="./assets"
PDF_DIR="$OUTPUT_DIR/documents"
IMG_DIR="$OUTPUT_DIR/images"

mkdir -p "$PDF_DIR" "$IMG_DIR"

echo "============================================"
echo "  Residents Response — Asset Scraper"
echo "============================================"
echo ""

PAGES=(
  "/"
  "/about"
  "/my-blog"
  "/fire-safety"
  "/post/letter-of-questions-to-barnet-council-regarding-the-re-cladding-of-homes"
)

TMPFILE=$(mktemp)

for page in "${PAGES[@]}"; do
  echo "📄 Fetching page: ${SITE_URL}${page}"
  curl -sL "${SITE_URL}${page}" >> "$TMPFILE" 2>/dev/null || true
done

echo ""
echo "============================================"
echo "  Extracting PDF/Document links..."
echo "============================================"

grep -oE 'https?://www\.residentsresponse\.com/_files/ugd/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(pdf|docx)' | sort -u > /tmp/rr_pdf_urls.txt || true
grep -oE '/_files/ugd/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(pdf|docx)' | sort -u | while read -r rel; do
  echo "${SITE_URL}${rel}"
done >> /tmp/rr_pdf_urls.txt

sort -u /tmp/rr_pdf_urls.txt > /tmp/rr_pdf_dedup.txt
mv /tmp/rr_pdf_dedup.txt /tmp/rr_pdf_urls.txt

PDF_COUNT=$(wc -l < /tmp/rr_pdf_urls.txt | tr -d ' ')
echo "Found $PDF_COUNT document links."
echo ""

COUNTER=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  COUNTER=$((COUNTER + 1))
  FILENAME=$(echo "$url" | sed 's|.*ugd/||' | sed 's|%20|_|g' | sed 's|?.*||')
  [ -z "$FILENAME" ] && FILENAME="document_${COUNTER}.pdf"
  echo "  [$COUNTER/$PDF_COUNT] $FILENAME"
  curl -sL -o "$PDF_DIR/$FILENAME" "$url" 2>/dev/null || echo "    FAILED: $url"
done < /tmp/rr_pdf_urls.txt

echo ""
echo "============================================"
echo "  Extracting image links..."
echo "============================================"

grep -oE 'https://static\.wixstatic\.com/media/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(png|jpg|jpeg|gif|webp|svg)' | sort -u > /tmp/rr_img_urls.txt || true

> /tmp/rr_img_clean.txt
while IFS= read -r img_url; do
  [ -z "$img_url" ] && continue
  echo "$img_url" | sed 's|/v1/fill/[^/]*||' | sed 's|/v1/crop/[^/]*||'
done < /tmp/rr_img_urls.txt | sort -u > /t
cat > scrape-assets.sh << 'ENDOFSCRIPT'
#!/bin/bash
set -euo pipefail

SITE_URL="https://www.residentsresponse.com"
OUTPUT_DIR="./assets"
PDF_DIR="$OUTPUT_DIR/documents"
IMG_DIR="$OUTPUT_DIR/images"

mkdir -p "$PDF_DIR" "$IMG_DIR"

echo "============================================"
echo "  Residents Response — Asset Scraper"
echo "============================================"
echo ""

PAGES=(
  "/"
  "/about"
  "/my-blog"
  "/fire-safety"
  "/post/letter-of-questions-to-barnet-council-regarding-the-re-cladding-of-homes"
)

TMPFILE=$(mktemp)

for page in "${PAGES[@]}"; do
  echo "📄 Fetching page: ${SITE_URL}${page}"
  curl -sL "${SITE_URL}${page}" >> "$TMPFILE" 2>/dev/null || true
done

echo ""
echo "============================================"
echo "  Extracting PDF/Document links..."
echo "============================================"

grep -oE 'https?://www\.residentsresponse\.com/_files/ugd/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(pdf|docx)' | sort -u > /tmp/rr_pdf_urls.txt || true
grep -oE '/_files/ugd/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(pdf|docx)' | sort -u | while read -r rel; do
  echo "${SITE_URL}${rel}"
done >> /tmp/rr_pdf_urls.txt

sort -u /tmp/rr_pdf_urls.txt > /tmp/rr_pdf_dedup.txt
mv /tmp/rr_pdf_dedup.txt /tmp/rr_pdf_urls.txt

PDF_COUNT=$(wc -l < /tmp/rr_pdf_urls.txt | tr -d ' ')
echo "Found $PDF_COUNT document links."
echo ""

COUNTER=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  COUNTER=$((COUNTER + 1))
  FILENAME=$(echo "$url" | sed 's|.*ugd/||' | sed 's|%20|_|g' | sed 's|?.*||')
  [ -z "$FILENAME" ] && FILENAME="document_${COUNTER}.pdf"
  echo "  [$COUNTER/$PDF_COUNT] $FILENAME"
  curl -sL -o "$PDF_DIR/$FILENAME" "$url" 2>/dev/null || echo "    FAILED: $url"
done < /tmp/rr_pdf_urls.txt

echo ""
echo "============================================"
echo "  Extracting image links..."
echo "============================================"

grep -oE 'https://static\.wixstatic\.com/media/[^"'"'"' ><)]+' "$TMPFILE" | grep -E '\.(png|jpg|jpeg|gif|webp|svg)' | sort -u > /tmp/rr_img_urls.txt || true

> /tmp/rr_img_clean.txt
while IFS= read -r img_url; do
  [ -z "$img_url" ] && continue
  echo "$img_url" | sed 's|/v1/fill/[^/]*||' | sed 's|/v1/crop/[^/]*||'
done < /tmp/rr_img_urls.txt | sort -u > /tmp/rr_img_clean.txt

IMG_COUNT=$(wc -l < /tmp/rr_img_clean.txt | tr -d ' ')
echo "Found $IMG_COUNT unique images."
echo ""

COUNTER=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  COUNTER=$((COUNTER + 1))
  FILENAME=$(echo "$url" | sed 's|.*/media/||' | sed 's|~mv2||' | sed 's|%20|_|g' | sed 's|?.*||')
  [ -z "$FILENAME" ] && FILENAME="image_${COUNTER}.png"
  echo "  [$COUNTER/$IMG_COUNT] $FILENAME"
  curl -sL -o "$IMG_DIR/$FILENAME" "$url" 2>/dev/null || echo "    FAILED: $url"
done < /tmp/rr_img_clean.txt

rm -f "$TMPFILE" /tmp/rr_pdf_urls.txt /tmp/rr_img_urls.txt /tmp/rr_img_clean.txt

echo ""
echo "============================================"
echo "  Done!"
echo "============================================"
echo "  Documents: $(ls -1 "$PDF_DIR" 2>/dev/null | wc -l | tr -d ' ') files"
echo "  Images:    $(ls -1 "$IMG_DIR" 2>/dev/null | wc -l | tr -d ' ') files"
echo "  Total size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
echo ""
