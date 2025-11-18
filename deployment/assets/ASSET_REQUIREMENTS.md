# Asset Requirements - Hisaab

## App Icon Design

### Technical Specifications

| Specification | Requirement |
|---------------|-------------|
| Size | 512 x 512 pixels |
| Format | PNG (32-bit) |
| Color Space | sRGB |
| Transparency | No alpha channel |
| File Size | < 1 MB |
| DPI | 72 or higher |

### Design Guidelines

**DO:**
- ✅ Use simple, recognizable symbols
- ✅ Keep it clean and minimal
- ✅ Make it work at small sizes (48x48 px)
- ✅ Use high contrast colors
- ✅ Follow Material Design principles
- ✅ Test on light and dark backgrounds
- ✅ Make it distinctive and memorable

**DON'T:**
- ❌ Use photos or complex imagery
- ❌ Include text (especially small text)
- ❌ Use too many colors (max 2-3)
- ❌ Make it too detailed
- ❌ Copy other apps' icons
- ❌ Use gradients excessively
- ❌ Include rounded corners (Android adds them)

### Icon Concept Ideas

**Option 1: Ledger Book with ₹ Symbol**
```
Simple ledger/notebook icon with Indian Rupee symbol (₹) integrated
Colors: Deep Blue (#1976D2) + Orange (#FF6F00)
Style: Flat, minimal
```

**Option 2: Calculator + Khata**
```
Stylized calculator merged with account book
Colors: Teal (#00897B) + Deep Orange (#BF360C)
Style: Material Design
```

**Option 3: "H" Monogram**
```
Stylized "H" with financial elements (₹, ledger lines)
Colors: Indigo (#3F51B5) + Amber (#FFC107)
Style: Modern, bold
```

### Adaptive Icon (Android)

Create additional layers for Android adaptive icons:

1. **Foreground Layer**: 108 x 108 dp (main icon, safe zone: 66 dp circle)
2. **Background Layer**: 108 x 108 dp (solid color or simple pattern)

**Safe Zone**: Keep important elements within 66 dp diameter circle

**Example Structure:**
```
res/
  mipmap-xxxhdpi/
    ic_launcher.png (192 x 192 px)
  mipmap-xxhdpi/
    ic_launcher.png (144 x 144 px)
  mipmap-xhdpi/
    ic_launcher.png (96 x 96 px)
  mipmap-hdpi/
    ic_launcher.png (72 x 72 px)
  mipmap-mdpi/
    ic_launcher.png (48 x 48 px)
```

## Splash Screen

### Specifications

| Element | Requirement |
|---------|-------------|
| Background | Solid color (match app theme) |
| Logo | Center-aligned, 200-300 px |
| Duration | < 2 seconds |
| Animation | Optional fade-in |

### Design

```
┌─────────────────────────┐
│                         │
│                         │
│       [App Icon]        │  ← 200-300 px
│                         │
│        Hisaab           │  ← App name (optional)
│                         │
│                         │
└─────────────────────────┘
```

**Colors:**
- Background: Primary color (#1976D2) or white
- Logo: White or primary color (high contrast)

## Screenshots

### Phone Screenshots (4-8 required)

**Specifications:**
- Resolution: 1080 x 1920 px (minimum)
- Aspect Ratio: 16:9 or 9:16
- Format: PNG or JPEG
- File Size: < 1 MB each
- Quality: High (no compression artifacts)

**Recommended Screenshots:**

1. **Customer List Screen**
   - Shows multiple customers with balances
   - Highlight color coding (red for payable, green for receivable)
   - Caption: "Manage All Your Customers"

2. **Transaction Details**
   - Shows a customer's transaction history
   - Visible credit/debit entries
   - Running balance
   - Caption: "Track Every Transaction"

3. **Invoice Screen**
   - Professional invoice with items
   - GST details visible
   - Clean, business-ready layout
   - Caption: "Create Professional Invoices"

4. **Reports Dashboard**
   - Shows report types (Ledger, P&L, Balance Sheet)
   - Visual emphasis on PDF export
   - Caption: "Generate Business Reports"

5. **Ledger Report**
   - Sample ledger report for a customer
   - Highlights opening/closing balance
   - Transaction list visible
   - Caption: "Detailed Customer Ledger"

6. **Hindi Interface** (Optional)
   - Same screen in Hindi
   - Shows bilingual support
   - Caption: "पूर्ण हिंदी समर्थन"

7. **Dark Mode** (Optional)
   - App in dark theme
   - Shows beautiful dark UI
   - Caption: "Beautiful Dark Theme"

8. **Backup & Export** (Optional)
   - Shows backup/export options
   - Highlights data safety
   - Caption: "Secure Backup & Export"

### Screenshot Tips

**Enhancement:**
- Add device frame (optional)
- Use consistent device models
- Add subtle drop shadow
- Ensure text is readable
- Use actual data (not Lorem Ipsum)

**Tools:**
- [Figma](https://figma.com) - Design screenshots
- [Shotbot](https://shotbot.io) - Add device frames
- [Screenshot Design](https://screenshots.pro) - Professional templates

### Tablet Screenshots (Optional)

**Specifications:**
- Resolution: 2560 x 1800 px or 1920 x 1200 px
- Aspect Ratio: 16:10
- Shows tablet-optimized layout
- 2-4 screenshots

## Feature Graphic

### Specifications

| Specification | Requirement |
|---------------|-------------|
| Size | 1024 x 500 pixels |
| Format | PNG or JPEG |
| File Size | < 1 MB |
| Safe Zone | Avoid text in edge 20 px |

### Design Template

```
┌──────────────────────────────────────────────┐
│  [Icon]  Hisaab - Khatabook for Business    │
│                                              │
│  Manage Customers • Track Money • Reports   │
│  ✓ Free  ✓ Offline  ✓ Hindi + English      │
└──────────────────────────────────────────────┘
```

### Design Elements

**Left Side (200 px):**
- App icon or graphic

**Middle (600 px):**
- App name in large, bold text
- Tagline or key features
- Bullet points of benefits

**Right Side (200 px):**
- Screenshot preview or device mockup (optional)

**Colors:**
- Background: Gradient (Primary to Accent) or solid
- Text: High contrast (white on dark, dark on light)
- Accents: Brand colors

### Tools for Creation

- **Figma**: Free, professional design tool
- **Canva**: Templates available
- **Adobe Photoshop**: Professional tool
- **GIMP**: Free alternative to Photoshop

## Video (Optional)

### Specifications

| Element | Requirement |
|---------|-------------|
| Duration | 30 seconds - 2 minutes |
| Format | MOV or MP4 |
| Resolution | 1920 x 1080 (Full HD) or higher |
| File Size | < 100 MB |
| Frame Rate | 24-30 fps |
| Audio | Optional background music |

### Video Script Template

**0-5 seconds:** Opening
- Show problem: Messy paper ledgers, calculation errors

**5-15 seconds:** Introduce Hisaab
- Show app icon and name
- Quick overview of main screen

**15-30 seconds:** Key Features
- Customer management
- Transaction recording
- Invoice generation

**30-45 seconds:** Reports & Export
- Show report generation
- Highlight PDF export
- Show data export

**45-50 seconds:** Benefits
- Hindi support
- Offline capability
- Free to use

**50-60 seconds:** Call to Action
- "Download Hisaab Today"
- Show Play Store icon
- App icon final frame

### Video Tips

- Keep it fast-paced
- Use actual app screens (screen recording)
- Add text overlays for clarity
- Background music: Upbeat, professional
- Voiceover: Clear, enthusiastic (optional)
- Showcase actual use case

## Branding Colors

### Primary Palette

```
Primary: #1976D2 (Blue)
Primary Dark: #1565C0
Primary Light: #BBDEFB

Secondary: #FF6F00 (Orange)
Secondary Dark: #E65100
Secondary Light: #FFE0B2

Success: #4CAF50 (Green)
Error: #F44336 (Red)
Warning: #FFC107 (Amber)
```

### Usage

- **Primary**: Main UI elements, buttons, headers
- **Secondary**: Accents, highlights, FAB
- **Success**: Positive balances, completed actions
- **Error**: Negative balances, errors
- **Warning**: Alerts, reminders

## Typography

### Fonts

**App UI:**
- Default system font (Roboto on Android)
- Support for Hindi fonts

**Marketing Materials:**
- Heading: Roboto Bold / Poppins Bold
- Body: Roboto Regular / Open Sans
- Hindi: Noto Sans Devanagari

### Text Sizes (Marketing)

- Main Headline: 48-72 px
- Subheading: 24-36 px
- Body Text: 14-18 px
- Captions: 12-14 px

## Asset Checklist

### Required Assets

- [ ] App icon 512x512 px (Play Store)
- [ ] Adaptive icon foreground layer
- [ ] Adaptive icon background layer
- [ ] Icon in all densities (mdpi to xxxhdpi)
- [ ] 4-8 phone screenshots
- [ ] Feature graphic 1024x500 px
- [ ] Privacy policy (hosted)

### Optional Assets

- [ ] 2-4 tablet screenshots
- [ ] Promotional video (30-120 seconds)
- [ ] YouTube thumbnail
- [ ] Social media graphics
- [ ] Website banner
- [ ] Email signature

## Tools & Resources

### Design Tools

- **Figma**: https://figma.com (Free, collaborative)
- **Adobe XD**: https://adobe.com/xd (Free plan available)
- **Canva**: https://canva.com (Templates)
- **GIMP**: https://gimp.org (Free Photoshop alternative)

### Icon Generators

- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/
- **App Icon Generator**: https://appicon.co
- **Adaptive Icon**: https://icon.kitchen

### Screenshot Tools

- **Shotbot**: https://shotbot.io (Device frames)
- **Mockuper**: https://mockuper.net (Device mockups)
- **Da Button Factory**: https://dabuttonfactory.com (Buttons)

### Stock Resources

- **Icons**: Material Icons, Font Awesome
- **Illustrations**: undraw.co, humaaans.com
- **Photos**: unsplash.com, pexels.com (if needed)

## Quality Checklist

Before submitting assets:

- [ ] All dimensions exact (not scaled)
- [ ] High resolution (no pixelation)
- [ ] Colors accurate (sRGB)
- [ ] Text readable at all sizes
- [ ] No typos or errors
- [ ] Consistent branding
- [ ] Professional appearance
- [ ] Files under size limits
- [ ] Correct file formats
- [ ] All required assets included

## Common Mistakes to Avoid

1. ❌ Low resolution images
2. ❌ Inconsistent branding
3. ❌ Text too small to read
4. ❌ Using copyrighted material
5. ❌ Not testing on devices
6. ❌ Ignoring safe zones
7. ❌ Too much text in icon
8. ❌ Poor color contrast
9. ❌ Outdated screenshots
10. ❌ Wrong aspect ratios

---

**Pro Tip**: Create all assets in high resolution first, then scale down. Never upscale low-res images!
