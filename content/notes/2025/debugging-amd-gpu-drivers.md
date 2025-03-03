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

...

### Mesa's RustICL Driver and the gfx1013

This actually works great, but applications like `llama.cpp`'s OpenCL backend depend on subgroup support (`cl_khr_subgroups`) plus resizable subgroups (`cl_intel_required_subgroup_size` or `cl_qcom_reqd_sub_group_size`). The core subgroup functionality is [supported by RustICL](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/22893), but the resizable subgroup functionality is not. Below is an initial hacked together patch to not get bogged down by this issue.

<https://github.com/mikekasprzak/llama.cpp/tree/amd-opencl>

Another issue across all drivers is that there's something wrong with how available memory reporting works. The version of the issue raised by [RustICL is here](https://gitlab.freedesktop.org/mesa/mesa/-/issues/9844), showing up as ~2 GB of VRAM when there should be 12 GB. Fudamentally this seems to a problem with the DKMS driver, but the lead behind RustICL [has a workaround](https://gitlab.freedesktop.org/karolherbst/mesa/-/commit/2260472bb65972339fe5dcc525093db23db0d2dc).

Unfortunately `llama.cpp`' OpenCL backend depends on another important feature: `cl_khr_fp16`. This is not supported by RustICL. I didn't see a quick road for me to "hacking this in" (I have limited Rust experence), so I chose to end my journey here.


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
  * I haven't done too much digging, but a Phoronix article suggested pefermance overall is better in the Mesa RADV driver, EXCEPT in Raytracing workloads.
  * Conjecture: Given that Mesa RADV is now the default, it may mean that AMD is low-key deprecating support for their Vulkan driver.
* More options can be seen with `amdgpu-install --list-usecase`

NOTE: Last I checked, the `vulkan-amdvlk` driver was missing from the ROCm 6.3.3 repository, so I had to switch to ROCm 6.3.2. This can be done with `amdgpu-setup -r 6.3.2`.

NOTE2: If you're on `Pop_OS!`, you may need to modify `amdgpu-install` and `amdgpu-setup` to include `pop` on the list of supported distributions. Simply edit the file `sudo nano /usr/bin/amdgpu-install`, search for `ubuntu` and add `|pop` to the list of Debian compatible OSes. Do the same for `amdgpu-setup`.

NOTE3: If you forget to use `--no-dkms`, it _may_ not actually rebuild the kernel with the `amdgpu-dkms` driver... or specifically, the Mesa RADV dkms driver may still be the priority (use `lsmod` and `modinfo amdgpu` to check which is loaded). You need to uninstall the Mesa RADV dkms driver before installing `amdgpu-dkms` to correctly get a Linux kernel built with it.


## Investigating related issues

This [github discussion](https://github.com/ROCm/ROCm/discussions/4030) is about a change noticed in the ROCm driver that broke a popular hack. As of ROCm 5.2 you were able to use a `gfx1010` series GPUs by tricking the ROCm driver into thinking it was a `gfx1030` GPU with `export HSA_OVERRIDE_GFX_VERSION=10.3.0`. As of ROCm 5.3 this no longer works.

I've used the same workaround with the `gfx1013` with mixed results. Do note it only works with AMD's drivers (i.e. ROCm, AMDVLK, etc), and not Mesa/ROCV/RustICL. This will be especially important if you're trying to use the rocBlas math libraries, as there are no `gfx1013` kernels included with AMD's releases. Saying the card is a `gfx1010`, `gfx1012`, or `gfx1030` will find kernels (`gfx1030` being the most complete), but there are issues with compute queues to deal with first. Also for my own reference `gfx906` exists, and it _may_ be usefur for getting my `gfx90c` integrated laptop GPU working.

Miners were apparently able to work around the compute problems, and even squeeze out some additional performance. This coversation, followed by [this other conversation](https://www.reddit.com/r/linux4noobs/comments/1bvdfi3/comment/lv80bw5/) is where I first discovered something called ["Smart Tune"](https://bitcointalk.org/index.php?topic=5088988.0), a proprietary script included with [mmpOS](https://mmpos.eu/). I still need to take a look at what the script actually does, in case it's something that will help us.
