import tkinter as tk
from tkinter import filedialog
import os
from PIL import Image, ImageTk

# Atlas element dimensions
ELEMENT_WIDTH = 32
ELEMENT_HEIGHT = 40
ZOOM = 2
N_COLS_BUFFER = 10
N_ROWS_BUFFER = 4
MAX_HEIGHT = 450
MAX_WIDTH = 500

class AtlasSelectorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Atlas Element Selector")
        
        # Add a top frame for buttons
        self.btn_frame = tk.Frame(root, bg="#1e1e1e")
        self.btn_frame.pack(fill=tk.X, side=tk.TOP)
        
        self.generate_btn = tk.Button(self.btn_frame, text="Generate PNG Strip", command=self.generate_strip)
        self.generate_btn.pack(pady=5)
        
        # Setup canvas for displaying the image
        self.canvas = tk.Canvas(root, bg="#1e1e1e", highlightthickness=0)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        
        # Bind left click
        self.canvas.bind("<Button-1>", self.on_click)
        
        # Bind Escape key to reload image
        self.root.bind("<Escape>", lambda e: self.open_image())
        
        self.photo = None
        self.pil_image = None
        self.current_zoom = ZOOM
        self.columns = 0
        self.rows = 0
        
        # Output buffer
        self.strip_buffer = Image.new("RGBA", (N_COLS_BUFFER * ELEMENT_WIDTH, N_ROWS_BUFFER * ELEMENT_HEIGHT), (0, 0, 0, 0))
        self.current_index = 0
        
        # Setup preview window
        self.preview_win = tk.Toplevel(root)
        self.preview_win.title("Preview Strip")
        self.preview_canvas = tk.Canvas(self.preview_win, bg="#333333", highlightthickness=0)
        self.preview_canvas.pack(fill=tk.BOTH, expand=True)
        self.preview_canvas.bind("<Button-1>", self.on_preview_click)
        self.preview_photo = None
        self.selected_images = []
        self.update_preview()
        
        # Prompt for image shortly after startup
        self.root.after(100, self.open_image)
        
    def open_image(self):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        initial_dir = os.path.join(script_dir, "..", "assets/tilesets")
        
        file_path = filedialog.askopenfilename(
            title="Select Atlas PNG",
            initialdir=initial_dir,
            filetypes=[("PNG Files", "*.png"), ("All Files", "*.*")]
        )
        
        if not file_path:
            print("No file selected.")
            return
            
        try:
            self.pil_image = Image.open(file_path).convert("RGBA")
            img_width, img_height = self.pil_image.size
            
            if img_width > MAX_WIDTH or img_height > MAX_HEIGHT:
                self.current_zoom = 1.5
            else:
                self.current_zoom = ZOOM
                
            display_width = int(img_width * self.current_zoom)
            display_height = int(img_height * self.current_zoom)
            
            display_image = self.pil_image.resize((display_width, display_height), Image.NEAREST)
            self.photo = ImageTk.PhotoImage(display_image)
        except Exception as e:
            print(f"Failed to load image: {e}")
            return
            
        # Clear previous image and grid lines
        self.canvas.delete("all")
        
        scaled_element_width = int(ELEMENT_WIDTH * self.current_zoom)
        scaled_element_height = int(ELEMENT_HEIGHT * self.current_zoom)
        
        self.columns = img_width // ELEMENT_WIDTH
        self.rows = img_height // ELEMENT_HEIGHT
        
        print(f"Loaded: {os.path.basename(file_path)}")
        print(f"Atlas dimensions: {img_width}x{img_height} (Zoomed to {display_width}x{display_height})")
        print(f"Grid size: {self.columns} columns x {self.rows} rows (Element: {ELEMENT_WIDTH}x{ELEMENT_HEIGHT})")
        
        # Resize window to fit image exactly plus button frame
        self.canvas.config(width=display_width, height=display_height)
        
        self.root.update_idletasks() # Ensure btn_frame height is calculated
        total_height = display_height + self.btn_frame.winfo_height()
        self.root.geometry(f"{display_width}x{total_height}")
        self.root.resizable(False, False) # Lock window size
        
        # Draw image on canvas
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.photo)
        
        # Draw grid
        for i in range(self.columns + 1):
            x = i * scaled_element_width
            self.canvas.create_line(x, 0, x, display_height, fill="#555555", dash=(2, 4))
        for j in range(self.rows + 1):
            y = j * scaled_element_height
            self.canvas.create_line(0, y, display_width, y, fill="#555555", dash=(2, 4))
            
        # Update preview to reposition it
        self.update_preview()
            
    def on_click(self, event):
        if not self.photo:
            return
            
        scaled_element_width = int(ELEMENT_WIDTH * self.current_zoom)
        scaled_element_height = int(ELEMENT_HEIGHT * self.current_zoom)
            
        col = event.x // scaled_element_width
        row = event.y // scaled_element_height
        
        if 0 <= col < self.columns and 0 <= row < self.rows:
            max_elements = N_COLS_BUFFER * N_ROWS_BUFFER
            if len(self.selected_images) >= max_elements:
                print(f"Buffer is full! ({max_elements} elements)")
                return
                
            print(f"Clicked element -> Row: {row}, Column: {col}")
            
            if self.pil_image:
                x0 = col * ELEMENT_WIDTH
                y0 = row * ELEMENT_HEIGHT
                x1 = x0 + ELEMENT_WIDTH
                y1 = y0 + ELEMENT_HEIGHT
                
                element_img = self.pil_image.crop((x0, y0, x1, y1))
                self.selected_images.append(element_img)
                self.render_buffer()
        else:
            # Clicked outside the logical grid boundaries
            pass

    def render_buffer(self):
        self.strip_buffer = Image.new("RGBA", (N_COLS_BUFFER * ELEMENT_WIDTH, N_ROWS_BUFFER * ELEMENT_HEIGHT), (0, 0, 0, 0))
        for idx, img in enumerate(self.selected_images):
            dest_col = idx % N_COLS_BUFFER
            dest_row = idx // N_COLS_BUFFER
            dest_x = dest_col * ELEMENT_WIDTH
            dest_y = dest_row * ELEMENT_HEIGHT
            self.strip_buffer.paste(img, (dest_x, dest_y), img)
        self.current_index = len(self.selected_images)
        self.update_preview()

    def on_preview_click(self, event):
        scaled_element_width = int(ELEMENT_WIDTH * self.current_zoom)
        scaled_element_height = int(ELEMENT_HEIGHT * self.current_zoom)
        
        col = event.x // scaled_element_width
        row = event.y // scaled_element_height
        
        index = row * N_COLS_BUFFER + col
        if 0 <= index < len(self.selected_images):
            print(f"Removed element from slot: {index}")
            self.selected_images.pop(index)
            self.render_buffer()

    def update_preview(self):
        # Zoom the preview so it's easily visible
        preview_width = int(N_COLS_BUFFER * ELEMENT_WIDTH * self.current_zoom)
        preview_height = int(N_ROWS_BUFFER * ELEMENT_HEIGHT * self.current_zoom)
        zoomed_buffer = self.strip_buffer.resize((preview_width, preview_height), Image.NEAREST)
        
        self.preview_photo = ImageTk.PhotoImage(zoomed_buffer)
        
        self.preview_canvas.config(width=preview_width, height=preview_height)
        self.preview_canvas.delete("all")
        self.preview_canvas.create_image(0, 0, anchor=tk.NW, image=self.preview_photo)
        
        self.root.update_idletasks()
        
        # Determine position below the main window
        y = self.root.winfo_y()
        # Fallback if winfo_y is too low (e.g. before full init)
        root_x = self.root.winfo_x()
        x = (root_x if root_x > 0 else 100) + self.root.winfo_width() + 40
        
        # Adjust preview window size and position
        self.preview_win.geometry(f"{preview_width}x{preview_height}+{x}+{y}")

    def generate_strip(self):
        if self.current_index == 0:
            print("No elements selected yet.")
            return
            
        script_dir = os.path.dirname(os.path.abspath(__file__))
        output_png = os.path.join(script_dir, "GeneratedStrip.png")
        
        self.strip_buffer.save(output_png, "PNG")
        print(f"Successfully saved strip to '{output_png}' with {self.current_index} elements.")

if __name__ == "__main__":
    root = tk.Tk()
    app = AtlasSelectorApp(root)
    root.mainloop()
