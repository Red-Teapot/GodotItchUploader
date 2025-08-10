# Godot Itch Uploader

This addon allows automatically exporting and uploading your project to [Itch.io](https://itch.io/) using [Butler](https://itch.io/docs/butler/).

Made by humans, for humans.

# How to Use

1. [Install Butler](https://itch.io/docs/butler/installing.html).
2. [Authenticate Butler](https://itch.io/docs/butler/login.html).
3. Install and enable this addon.
4. Open `Project Settings`, navigate to the `Itch Uploader` section in the left panel, and fill the `Itch Page URL` field. It should contain the link to the project page on Itch, e.g.: `https://redteapot.itch.io/test`.
5. Configure your export presets. Make sure each export preset uses a separate empty folder to avoid packaging unnecessary files with your project.
6. Open the Project menu, then go to `Tools` -> `Export and Upload to Itch...`
8. If you have Butler in your `PATH`, skip this step. Otherwise, specify the path to the Butler executable in the `Butler path` field. It will be saved, so you won't have to do it again.
9. Select the export presets you want to export and click `Export and Upload`.
