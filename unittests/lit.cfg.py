# ./lit.cfg.py -*- Python -*-
#
# This file is licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# (c) Copyright 2021 Xilinx Inc.

import os
import platform
import re
import subprocess
import tempfile

import lit.formats
import lit.util

# from lit.llvm import llvm_config

config.name = "CMake LIT test"
config.test_format = lit.formats.ShTest(True)
config.test_source_root = os.path.join(os.path.dirname(__file__), "findTests")
if not hasattr(config, "test_exec_root"):
    config.test_exec_root = os.path.join(os.path.dirname(__file__))

cmake_root = os.path.join(os.path.dirname(__file__), "..")

if not hasattr(config, "cmake_opts"):
    config.cmake_opts = ""
config.substitutions.append(
    (
        "%cmake",
        "cmake -DCMAKE_MODULE_PATH="
        + cmake_root
        + ' -DCMAKE_FIND_LIBRARY_PREFIXES=lib -DCMAKE_FIND_LIBRARY_SUFFIXES=".a;.so" '
        + config.cmake_opts,
    )
)

if hasattr(config, "disable_checks"):
    config.substitutions.append(("%grep", "echo"))
else:
    config.substitutions.append(("%grep", "grep"))

# config.substitutions.append(('%vitis_root%', config.vitis_root))

config.suffixes = [".cmake"]
