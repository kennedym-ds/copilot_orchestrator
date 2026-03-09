from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations
import math

# Initialize the MCP server
mcp = FastMCP("Design System Pilot")

# Mock Data for Pilot
BRAND_PALETTE = [
    {"name": "Primary Blue", "hex": "#0052CC", "usage": "Buttons, Links"},
    {"name": "Secondary Teal", "hex": "#00B8D9", "usage": "Accents"},
    {"name": "Neutral Gray", "hex": "#42526E", "usage": "Text"},
    {"name": "Success Green", "hex": "#36B37E", "usage": "Success Messages"},
    {"name": "Warning Yellow", "hex": "#FFAB00", "usage": "Warnings"},
    {"name": "Danger Red", "hex": "#FF5630", "usage": "Errors"},
]

COMPONENTS = [
    {"name": "PrimaryButton", "status": "Stable", "docs": "https://design.example.com/button"},
    {"name": "SecondaryButton", "status": "Stable", "docs": "https://design.example.com/button"},
    {"name": "TextInput", "status": "Beta", "docs": "https://design.example.com/input"},
    {"name": "Modal", "status": "Deprecated", "docs": "https://design.example.com/modal"},
]

def _hex_to_rgb(hex_color: str):
    """Convert hex string to (r, g, b) tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def _luminance(r, g, b):
    """Calculate relative luminance."""
    a = [v / 255.0 for v in (r, g, b)]
    a = [((v + 0.055) / 1.055) ** 2.4 if v > 0.03928 else v / 12.92 for v in a]
    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722

def _contrast_ratio(l1, l2):
    """Calculate contrast ratio between two luminances."""
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def get_brand_palette() -> list[dict]:
    """
    Returns the official brand color palette.
    Use this to find approved hex codes for UI elements.
    """
    return BRAND_PALETTE

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def check_contrast(fg_hex: str, bg_hex: str) -> dict:
    """
    Calculates the contrast ratio between a foreground and background color.
    Returns the ratio and whether it passes WCAG AA standards (4.5:1).
    """
    try:
        rgb1 = _hex_to_rgb(fg_hex)
        rgb2 = _hex_to_rgb(bg_hex)
        
        l1 = _luminance(*rgb1)
        l2 = _luminance(*rgb2)
        
        ratio = _contrast_ratio(l1, l2)
        pass_aa = ratio >= 4.5
        
        return {
            "ratio": round(ratio, 2),
            "pass_AA": pass_aa,
            "foreground": fg_hex,
            "background": bg_hex
        }
    except Exception as e:
        return {"error": str(e), "pass_AA": False, "ratio": 0.0}

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def search_components(query: str) -> list[dict]:
    """
    Search for approved UI components in the design system.
    Returns component names, status, and documentation URLs.
    """
    query = query.lower()
    return [c for c in COMPONENTS if query in c["name"].lower()]

if __name__ == "__main__":
    mcp.run()
