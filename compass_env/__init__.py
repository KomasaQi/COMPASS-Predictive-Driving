import os
import sys

from gymnasium.envs.registration import register


__version__ = "1.0.1"

try:
    from farama_notifications import notifications

    if "compass_highway_env" in notifications and __version__ in notifications["gymnasium"]:
        print(notifications["compass_highway_env"][__version__], file=sys.stderr)

except Exception:  # nosec
    pass

# Hide pygame support prompt
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"

def _register_compass_envs():
    """Import the compass_env module so that envs register themselves."""

    # exit_env.py
    register(
        id="compass-highway-v0",
        entry_point="compass_env.envs.compass_highway_env:CompassHighwayEnv",
        max_episode_steps=500,
    )


    register(
        id="compass-highway-v1",
        entry_point="compass_env.envs.compass_parallel_env:CompassParallelEnv",
        max_episode_steps=500,
    )

    register(
        id="compass-highway-v2",
        entry_point="compass_env.envs.compass_fast_parallel_env:CompassFastParallelEnv",
        max_episode_steps=500,
    )

_register_compass_envs()