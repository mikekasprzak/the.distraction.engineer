+++
+++

# Background

I picked up a pair of ASRock BC-250 blade servers for cheap ($70 each shipped). They're amazing little machines with a slightly paired down version of the PlayStation 5 APU. They nearly boot into a stock Ubuntu 24.04 install, but require a few small tweaks to get the GPU working.

Thanks to these machines, I found myself kernel hacking in an attempt at getting more GPU APIs working (ROCm, OpenCL, SYCL, etc).


## What's working today

### Mesa's RADV Driver and the gfx1013

This WIP patch allows Vulkan and OpenGL applications to start working.

<https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/33116>

The patch disables compute queues, which is known to cause the driver to crash. Many people have successfully run games with this patch, and it's in the final stages of doing test-suites to get it merged.

There's still an issue where the GPU isn't able to see all 12 GB of memory (in a 4/12 configuration). You can find a workaround here, though it actually makes MORE VRAM available to the GPU than allocated.

TODO LINK THAT

TODO Preface this:

The [sg_display](https://docs.kernel.org/gpu/amdgpu/module-parameters.html) setting seems to be an `amdgpu-dkms` workaround for screen flickering.

### Mesa's RustICL Driver and the gfx1013

<https://docs.mesa3d.org/rusticl.html>

<https://docs.mesa3d.org/envvars.html#envvar-RUSTICL_ENABLE>

This actually works great (just be sure to `export RUSTICL_ENABLE=1`), but applications like `llama.cpp`'s OpenCL backend depend on subgroup support ([]`cl_khr_subgroups`](https://registry.khronos.org/OpenCL/sdk/3.0/docs/man/html/cl_khr_subgroups.html), [man page](https://registry.khronos.org/OpenCL/sdk/3.0/docs/man/html/subGroupFunctions.html), [khronos docs](https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_C.html#sub-group-functions), [phoronix](https://www.phoronix.com/news/Rusticl-OpenCL-Subgroups)) plus resizable subgroups ([`cl_intel_required_subgroup_size`](https://registry.khronos.org/OpenCL/extensions/intel/cl_intel_required_subgroup_size.html) [(man page)](https://registry.khronos.org/OpenCL/extensions/intel/cl_intel_subgroups.html) or `cl_qcom_reqd_sub_group_size`). The core subgroup functionality is [supported by RustICL](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/22893), but the resizable subgroup functionality is not. Below is an initial hacked together patch to not get bogged down by this issue.

<https://github.com/mikekasprzak/llama.cpp/tree/amd-opencl>

Another issue across all drivers is that there's something wrong with how available memory reporting works. The version of the issue raised by [RustICL is here](https://gitlab.freedesktop.org/mesa/mesa/-/issues/9844), showing up as ~2 GB of VRAM when there should be 12 GB. Fudamentally this seems to a problem with the DKMS driver, but the lead behind RustICL [has a workaround](https://gitlab.freedesktop.org/karolherbst/mesa/-/commit/2260472bb65972339fe5dcc525093db23db0d2dc).

Unfortunately `llama.cpp`' [OpenCL backend](https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_C.html#cl_khr_fp16) depends on another important feature: [`cl_khr_fp16`](https://registry.khronos.org/OpenCL/sdk/3.0/docs/man/html/cl_khr_fp16.html). This is not supported by RustICL. I didn't see a quick road for me to "hacking this in" (I have limited Rust experence), so I chose to end my journey here.


### Installing (broken) AMD GPU and ROCm drivers

Following AMD's Linux Driver installation guide up until the last steps (i.e. don't install `amdgpu-dkms` or `rocm` yet).

<https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html>

Instead, use the `amdgpu-install` tool you just installed.

```bash
# If you previously installed Mesa
amdgpu-install --usecase=rocmdev,openclsdk,hiplibsdk --no-dkms

# Without Mesa, all AMD
amdgpu-install --usecase=rocmdev,openclsdk,hiplibsdk --vulkan=amdvlk
```

Adjust the line above for the components you do/don't want to install.

* If you previously built and installed the Mesa patches above, you don't need AMD's `dkms` driver, hence the `--no-dkms` flag.
* `rocm` includes the ROCr runtime built on KFD, the ROCr OpenCL and HIP (Cuda-like) runtimes, and all the non development tools
* `rocmdev` is the same but includes ROCm development tools and libraries
* `openclsdk` for the ROCr OpenCL development tools and libraries
* `liplibsdk` for the HIP (Cuda-like) development libraries
* `--vulkan=amdvlk` is required if you specifically want AMD's Vulkan driver (as opposed to the Mesa RADV driver).
  * YOU SHOULD ONLY DO THIS IF YOU ARE TINKERING! The Mesa RADV driver should be better supported.
  * I haven't done too much digging, but a [Phoronix article](https://www.phoronix.com/review/amdvlk-radv-rt/4) suggested pefermance overall is better in the Mesa RADV driver, EXCEPT in Raytracing workloads.
  * Conjecture: Given that Mesa RADV is now the default, it may mean that AMD is low-key deprecating support for their Vulkan driver.
* More options can be seen with `amdgpu-install --list-usecase`

NOTE: Last I checked, the `vulkan-amdvlk` driver was missing from the ROCm 6.3.3 repository, so I had to switch to ROCm 6.3.2. This can be done with `amdgpu-setup -r 6.3.2`.

NOTE2: If you're on `Pop_OS!`, you may need to modify `amdgpu-install` and `amdgpu-setup` to include `pop` on the list of supported distributions. Simply edit the file `sudo nano /usr/bin/amdgpu-install`, search for `ubuntu` and add `|pop` to the list of Debian compatible OSes. Do the same for `amdgpu-setup`.

NOTE3: If you forget to use `--no-dkms`, it _may_ not actually rebuild the kernel with the `amdgpu-dkms` driver... or specifically, the Mesa RADV dkms driver may still be the priority (use `lsmod` and `modinfo amdgpu` to check which is loaded). You need to uninstall the Mesa RADV dkms driver before installing `amdgpu-dkms` to correctly get a Linux kernel built with it.


## Investigating related issues

This [github discussion](https://github.com/ROCm/ROCm/discussions/4030) is about a change noticed in the ROCm driver that broke a [popular hack](https://github.com/ROCm/ROCm/issues/2216). Up to ROCm 5.2 you were able to use a `gfx1010` series GPUs by tricking the ROCm driver into thinking it was a `gfx1030` GPU with `export HSA_OVERRIDE_GFX_VERSION=10.3.0`. As of ROCm 5.3 this no longer works.

A [related bug](https://www.reddit.com/r/ROCm/comments/1bd8vde/psa_rdna1_gfx1010gfx101_gpus_should_start_working/) was supposedly fixed in ROCm 6.1, so it MAY actually work again. That said the `gfx1013` kernels may not be included in driver releases, and build rocBlas from source may require `-DTensile_LAZY_LIBRARY_LOADING=OFF` according to the post.

Supposedly there exists a ROCm version released with actual `gfx1013` support. ROCm 5.2 is a known good version that supports the "popular hack", not necessarily the `gfx1013` GPU. I have seen `gfx1013` listed in the ROCr runtime `CMakeFiles` targets, but not all targets.

I've used the same workaround with the `gfx1013` with mixed results. Do note it only works with AMD's drivers (i.e. ROCm, AMDVLK, etc), and not Mesa/ROCV/RustICL. This will be especially important if you're trying to use the rocBlas math libraries, as there are no `gfx1013` kernels included with AMD's releases. Saying the card is a `gfx1010`, `gfx1012`, or `gfx1030` will find kernels (`gfx1030` being the most complete), but there are issues with compute queues to deal with first. Also for my own reference `gfx906` exists, and it _may_ be usefur for getting my `gfx90c` integrated laptop GPU working.

AMD claims their APUs are not supported by the ROCm driver. [The tables here](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html) give you a handy list of alterntaive LLVM target names you can try like `export HSA_OVERRIDE_GFX_VERSION=10.3.0` for the `gfx1030`.

Miners were apparently able to work around the compute problems, and even squeeze out some additional performance. This coversation, followed by [this other conversation](https://www.reddit.com/r/linux4noobs/comments/1bvdfi3/comment/lv80bw5/) is where I first discovered something called ["Smart Tune"](https://bitcointalk.org/index.php?topic=5088988.0), a proprietary script included with [mmpOS](https://mmpos.eu/). I still need to take a look at what the script actually does, in case it's something that will help us.

<https://gitlab.freedesktop.org/mesa/mesa/-/issues/12713>


## Breaking down of the AMD Linux driver stack

* ROCm is the marketing name for AMD's compute driver stack. Everything you need to ROCK'em... I guess, lol.
* [RADV](https://docs.mesa3d.org/drivers/radv.html) is the AMDGPU Vulkan runtime built into Mesa.
* ??? where are the `AMDVLK` sources?
* [AMD CLR](https://github.com/ROCm/clr) are the actual compute runtimes for both HIP and OpenCL.
* [ROCr](https://rocm.docs.amd.com/projects/ROCR-Runtime/en/docs-6.3.3/index.html) is the HSA runtime library (`libhsakmt.so`), the part that interfaces with the `amdgpu-dkms` kernel module (AKA the KMT... Kernel Mode Thunk?).
  * Use `export HSAKMT_DEBUG_LEVEL=7` to log a variety of messages as calls are made to the ROCr runtume.
  * See the [System Debuggig](https://rocm.docs.amd.com/en/latest/how-to/system-debugging.html) for more information.
  * HSA KMT used to be here: <https://github.com/ROCm/ROCT-Thunk-Interface/>
* [HIP](https://rocm.docs.amd.com/projects/HIP/en/latest/what_is_hip.html) is a compute API that's remarkably similar to NVidia's CUDA. The actual runtime code is found in a shared codebase with OpenCL called "AMD CLR" (mentioned above).
  * HIP code is compiled using `hipcc`, a `clang++` wrapper with the "HIP stuff". It's the `nvcc` equivalent for ROCm.
  * There's an unusual graphic [here](https://rocm.docs.amd.com/projects/HIP/en/latest/what_is_hip.html) that suggests that HIP code can output both CUDA and HIP binaries, and that HIP binaries can run on both AMD and NVidia hardware.
* [ROCK Kernel Driver](https://github.com/ROCm/ROCK-Kernel-Driver/tree/master/drivers/gpu/drm/amd/amdgpu) is a fork of the Linux kernel that contains the `amdgpu-dkms` driver. In theory, these changes should get upstreamed into the Linux kernel (eventually).
* [SYCL](https://www.khronos.org/sycl/) is a Khronos standard pushed by Intel to further unify the compute APIs. Intel's [oneAPI DPC++ compiler](https://www.intel.com/content/www/us/en/developer/tools/oneapi/dpc-compiler-download.html) seems the most mature SYCL implementation.
  * SYCL supports both compiled and SPIR-V compute kernels, like Vulkan. SPIR-V is the default.
  * SPIR-V kernels need to be JIT compiled on the host machine before running, so startup time might be noticibly slow.
  * SYCL for _now_ supports HIP or OpenCL when targetting [AMD GPUs](https://developer.codeplay.com/products/oneapi/amd/2025.0.0/guides/index) (previously it was only OpenCL).
  * SYCL for supports both CUDA and PTX (i.e. NVidia Assembly) when targetting [NVidia GPUs](https://developer.codeplay.com/products/oneapi/nvidia/2025.0.0/guides/index).
  * SYCL also supports CPUs, so it can be slightly more work to ensure you're running on the best device.
  * Intel claims DPC++ kernel performance is better than CUDA on NVidia hardware (if true it's because of PTX).
* [ZLUDA](https://github.com/vosen/ZLUDA) is a "drop in" CUDA for AMD runtime.
* [SCALE](https://scale-lang.com/) by Spectral Compute is another "drop in" CUDA for AMD. [How does it compare?](https://docs.scale-lang.com/manual/comparison/)

### AMD GPU Architecture Manuals

<https://rocm.docs.amd.com/en/latest/conceptual/gpu-arch.html>

* [RDNA2](https://www.amd.com/content/dam/amd/en/documents/radeon-tech-docs/instruction-set-architectures/rdna2-shader-instruction-set-architecture.pdf)
* [RDNA1](https://www.amd.com/content/dam/amd/en/documents/radeon-tech-docs/instruction-set-architectures/rdna-shader-instruction-set-architecture.pdf)
* [Vega/MI25](https://www.amd.com/content/dam/amd/en/documents/radeon-tech-docs/instruction-set-architectures/vega-shader-instruction-set-architecture.pdf)

### Code notes

* ROCm
  * Post Install: <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>
  * GPU Isolation (for debugging): <https://rocm.docs.amd.com/en/latest/conceptual/gpu-isolation.html>
* HSA Runtime
  * [TRY & CATCH](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/runtime/hsa-runtime/core/runtime/hsa.cpp#L172) macros
  * [handleException](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/runtime/hsa-runtime/core/runtime/hsa_ext_amd.cpp#L154)
  * [debug_print](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/runtime/hsa-runtime/core/util/utils.h#L129)
  * runtime_singleton_ [dot h](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/runtime/hsa-runtime/core/inc/runtime.h#L153) [dot cpp](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/runtime/hsa-runtime/core/runtime/runtime.cpp#L111)
  * [hsaKmtFreeMemory](https://github.com/ROCm/ROCR-Runtime/blob/3ceb131df55f0bbc172615a23b014b55f11b5e20/libhsakmt/src/memory.c#L224)
* CLR Runtime
  * [ShouldNotReachHere](https://github.com/ROCm/clr/blob/0558a8cd8af8ae9d93f4e47359578b573bce7c14/rocclr/utils/debug.hpp#L130)
  * Null Device [globalFreeMemory](https://github.com/ROCm/clr/blob/0558a8cd8af8ae9d93f4e47359578b573bce7c14/rocclr/device/rocm/rocdevice.hpp#L284)
  * The one [atexit](https://github.com/ROCm/clr/blob/3ec1d2d2f1154b75806612fce06b15293ee59e00/opencl/tools/cltrace/cltrace.cpp#L4400) (meaning the issue is likely in a ~destructor or higher up, say in HSA or the kernel driver)
  * RockDevice.cpp
    * releaseQueue ["Deleting hardware queue XX with refCount 0"](https://github.com/ROCm/clr/blob/0558a8cd8af8ae9d93f4e47359578b573bce7c14/rocclr/device/rocm/rocdevice.cpp#L3092)
  * `hipStreamSynchronize(0)` to [wait for all kernels to finish](https://rocm.docs.amd.com/projects/HIP/en/latest/reference/hip_runtime_api/modules/stream_management.html#_CPPv420hipStreamSynchronize11hipStream_t), [more](https://rocm.docs.amd.com/projects/HIP/en/latest/how-to/hip_runtime_api/asynchronous.html)
  * Until I see otherwise, I think this is the compute kernel used by hipMemcpy [__amd_rocclr_fillBufferAligned](https://github.com/ROCm/clr/blob/0558a8cd8af8ae9d93f4e47359578b573bce7c14/rocclr/device/blitcl.cpp#L52)
    * [rocBlit?](https://github.com/ROCm/clr/blob/3ec1d2d2f1154b75806612fce06b15293ee59e00/rocclr/device/rocm/rocblit.hpp#L606)
    * [palBlit?](https://github.com/ROCm/clr/blob/3ec1d2d2f1154b75806612fce06b15293ee59e00/rocclr/device/pal/palblit.hpp#L547)
* [ERRNO errors](https://en.cppreference.com/w/cpp/error/errno_macros) as text
* [__cxa_finalie](https://refspecs.linuxbase.org/LSB_3.2.0/LSB-Core-generic/LSB-Core-generic/baselib---cxa_finalize.html) where atexit and destructors are called on program exit
* `fflush(stdout);` to forcefully flush printf
* `sleep(1);` to wait for a second `#include <unistd.h>`
* [building vllm](https://docs.vllm.ai/en/latest/getting_started/installation/gpu/index.html?device=rocm)
* llama.cpp
  * [GGML OPENCL KERNEL](https://github.com/ggml-org/llama.cpp/blob/1782cdfed60952f9ff333fc2ab5245f2be702453/ggml/src/ggml-opencl/kernels/ggml-opencl.cl)
  * [building with hip](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip)
  * [Official OpenCL instructions](https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/OPENCL.md)
  * The OpenCL branch I build with a similar invocation, but with `-DGGML_OPENCL=ON` and with the Qualcomm Adreno kernels disabled.
* HIP
  * Debugging and Tracing <https://rocm.docs.amd.com/projects/HIP/en/latest/how-to/debugging.html>
  * HIP Environment Variables <https://rocm.docs.amd.com/projects/HIP/en/docs-develop/reference/env_variables.html>
* OpenCL
  * [CL_DEVICE_TYPE_GPU](https://github.com/KhronosGroup/OpenCL-Headers/blob/main/CL/cl.h#L299) constant `(1 << 2)`
  * [CL_DEVICE_TYPE_SPECIAL](https://github.com/KhronosGroup/OpenCL-Headers/blob/main/CL/cl.h#L302) constant `(1 << 4)`, i.e. what I saw that RustICL driver thought my APU was, instead of a GPU
* MESA
  * How to build: <https://gitlab.freedesktop.org/mesa/mesa>
  * Another "How to build" page <https://docs.mesa3d.org/install.html>
  * Using Meson: <https://docs.mesa3d.org/meson.html>
* CUDA
  * [cudaFree](https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html)
* CMAKE
  * <https://github.com/Kitware/CMake/blob/c3ef56795102516c2d5c86b5d90808e854cda514/Modules/FindOpenCL.cmake>

### Misc links

* [AMD Powerplay](https://en.wikipedia.org/wiki/AMD_PowerPlay) is what power management for AMD GPUs (and APUs) is called. There's mentions of this in the `amdgpu-kernel` driver.
* [UCX](https://openucx.org/documentation/) an open communication framework, apparently
* [building the linux kernel](https://phoenixnap.com/kb/build-linux-kernel)
* <https://askubuntu.com/questions/1351911/what-does-regenerate-your-initramfs-mean>