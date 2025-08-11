# Godot Itch Uploader

This addon allows automatically exporting and uploading your project to [Itch.io](https://itch.io/) using [Butler](https://itch.io/docs/butler/).

**NOTE: This is a work-in-progress.** While this addon should functional, it may contain bugs. It's highly recommended to back up your project before using this addon.

Made by humans, for humans.

# How to Use

1. [Install Butler](https://itch.io/docs/butler/installing.html).
2. [Authenticate Butler](https://itch.io/docs/butler/login.html).
3. Install and enable this addon.
4. Open `Project Settings`, navigate to the `Itch Uploader` section in the left panel, and fill the `Itch Page URL` field. It should contain the link to the project page on Itch, e.g.: `https://redteapot.itch.io/test`.
5. Configure your export presets. Make sure each export preset uses a separate empty folder to avoid packaging unnecessary files with your project. For example, you could use these paths:

   - For Web, `.export/web/index.html`
   - For Windows, `.export/windows/game-name.exe`
   - For Linux, `.export/linux/game-name.x86_64`
   - For MacOS, `.export/macos/game-name.app`

   Don't forget to add the `.export` folder to the `.gitignore` file.

6. Open the Project menu, then go to `Tools` -> `Export and Upload to Itch...`
8. If you have Butler in your `PATH`, skip this step. Otherwise, specify the path to the Butler executable in the `Butler path` field. It will be saved, so you won't have to do it again.
9. Select the export presets you want to export and click `Export and Upload`.

# License

This addon is licensed under the terms of the [MIT License](LICENSE). The icons used by this addon are part of the [Godot Engine](https://godotengine.org/) and are licensed under the [MIT License](https://godotengine.org/license/).
