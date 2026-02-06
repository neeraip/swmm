import os
import subprocess
import sys

from ras_commander import RasProcess


def run_cmd(args, env=None):
    result = subprocess.run(
        args,
        text=True,
        capture_output=True,
        env=env,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stdout)
        sys.stderr.write(result.stderr)
        raise RuntimeError(f"Command failed: {' '.join(args)}")


def ensure_wine_components():
    env = {
        **os.environ,
        "WINEPREFIX": "/root/.wine",
        "WINEARCH": "win64",
        "DISPLAY": "",
        "XDG_RUNTIME_DIR": "/tmp/runtime-root",
    }

    print("Ensuring required Wine components are installed...")

    # Initialize the Wine prefix (requires xvfb)
    run_cmd(["xvfb-run", "-a", "wineboot", "--init"], env=env)

    # Install required components if missing
    status = RasProcess.check_wine_environment()
    if not status.get("corefonts"):
        run_cmd(["xvfb-run", "-a", "winetricks", "-q", "corefonts"], env=env)
    if not status.get("gdiplus"):
        run_cmd(["xvfb-run", "-a", "winetricks", "-q", "gdiplus"], env=env)
    if not status.get("dotnet48"):
        run_cmd(["xvfb-run", "-a", "winetricks", "-q", "dotnet48"], env=env)


# Configure Wine environment for container
RasProcess.configure_wine(
    wine_prefix="/root/.wine", ras_install_dir="/root/.wine/drive_c/HEC-RAS/6.6"
)

ensure_wine_components()

# Check Wine environment status
print("Checking Wine environment...")
status = RasProcess.check_wine_environment()
for key, value in status.items():
    print(f"  {key}: {value}")

# TODO: Add your HEC-RAS project setup here
# project_path = "/data/your_project.prj"
# init_ras_project(project_path, "6.6")
#
# View available plans
# print(ras.plan_df)
#
# Execute a plan
# plan_number = "01"
# num_cores = 4
# success = RasCmdr.compute_plan(
#     plan_number=plan_number,
#     dest_folder="/data/results",
#     num_cores=num_cores,
#     overwrite_dest=True,
# )
#
# print(f"Success: {success}")
