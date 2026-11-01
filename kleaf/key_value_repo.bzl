def _impl(repository_ctx):
    repository_content = ""
    defaults = {
        "DEFCONFIG_OVERLAYS": "",
        "KERNEL_VERSION": "",
        "SOURCE_DATE_EPOCH": "",
    }
    build_config_path = repository_ctx.path(Label("@//:build.config"))
    if build_config_path.exists:
        for line in repository_ctx.read(build_config_path).splitlines():
            line = line.strip()
            if line.startswith("KERNEL_DIR="):
                defaults["KERNEL_VERSION"] = line.partition("=")[2].strip("\"'")
            elif line.startswith("DEFCONFIG_OVERLAYS="):
                defaults["DEFCONFIG_OVERLAYS"] = line.partition("=")[2].strip("\"'")
    for key in ["DEFCONFIG_OVERLAYS", "KERNEL_VERSION", "SOURCE_DATE_EPOCH"]:
        if key in repository_ctx.os.environ and repository_ctx.os.environ[key].strip():
            value = repository_ctx.os.environ[key].strip()
        else:
            value = defaults[key]
        repository_content += '{} = "{}"\n'.format(key, value)

    for key, value in repository_ctx.attr.additional_values.items():
        repository_content += '{} = "{}"\n'.format(key, value)

    repository_ctx.file("BUILD", """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
bzl_library(
    name = "dict",
    srcs = ["dict.bzl"],
    visibility = ["//visibility:public"],
)
""", executable = False)
    repository_ctx.file("dict.bzl", repository_content, executable = False)

key_value_repo = repository_rule(
    implementation = _impl,
    local = True,
    environ = [
        "DEFCONFIG_OVERLAYS",
        "KERNEL_VERSION",
        "SOURCE_DATE_EPOCH",
    ],
    attrs = {
        "additional_values": attr.string_dict(),
    },
)
