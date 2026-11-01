load(
    "//build/kernel/kleaf:kernel.bzl",
    "kernel_module",
)
load(
    ":mgk.bzl",
    "kernel_versions_and_projects",
)

def define_mgk_ko(
        name,
        srcs = None,
        outs = None,
        deps = []):
    if srcs == None:
        srcs = native.glob(
            [
                "**/*.c",
                "**/*.h",
                "**/Kbuild",
                "**/Makefile",
            ],
            exclude = [
                ".*",
                ".*/**",
            ],
        )
    if outs == None:
        outs = [name + ".ko"]
    for version,projects in kernel_versions_and_projects.items():
        for project in projects.split(" "):
            for build in ["eng", "userdebug", "user", "ack"]:
                device_modules_dir = "kernel_device_modules-" + version
                kernel_module(
                    name = "{}.{}.{}.{}".format(name, project, version, build),
                    srcs = srcs,
                    outs = outs,
                    kernel_build = "//{}:{}.{}".format(device_modules_dir, project, build),
                    deps = [
                        "//{}:{}_modules.{}".format(device_modules_dir, project, build),
                    ] + ["{}.{}.{}.{}".format(m, project, version, build) for m in deps],
                )

