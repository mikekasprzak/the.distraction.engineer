+++
title = "Weird GPUs"
date = "2025-02-17T18:02:06.119Z"
summary = "This notebook collect information about atypical GPUs, and how they compare to more widely available consumer GPUs, with a focus on compute"
keywords = [ ]
tags = [ "amd", "cuda", "intel", "nvidia", "opencl", "rocm", "sycl" ]
categories = [ "compute", "gpu" ]
+++

## FP64 Workloads

Consumer GPUs tend to have poor 64bit floating point performance. That said, CPUs and GPUs are often "good enough" for most use cases. Unless you do simulation work, you don't likely need this.

| GPU                          | INTERFACE    | VRAM               | FP64 FMA (TFLOPS) | TDP (W) | PRICE (\~eBay)         | NOTES                           |
| ---------------------------- | ------------ | ------------------ |------------------ | ------- | ---------------------- | ------------------------------- |
| NVidia H100 (Hopper)[^tesla] | PCIe 4.0 x16 | 80GB               | 25.6              | 350     | 💰💰                   | SXM5 available                  |
| NVidia A100 (Ampere)[^tesla] | PCIe 4.0 x16 | 40/80GB            | 9.7               | 250     | 💰 (\~$5000/~$??)      | SXM4 available                  |
| NVidia V100 (Volta)[^tesla]  | PCIe 3.0 x16 | 12[^v100]/16/32GB  | 7.0               | 250     | \~$500/\~$650/\~$1800  | SXM2/SXM3 available             |


[^tesla]: <https://en.wikipedia.org/wiki/Nvidia_Tesla#Specifications>
[^v100]: Some 16 GB v100 cards on eBay are listed as "neutered". See also the CMP 100-210.


## SXM GPUs

Certain NVidia GPUs are also available as [SXM](https://en.wikipedia.org/wiki/SXM_(socket)), a proprietary NVidia interface. SXM can be adapted to PCIe with an adapter board.

| GPU                          | INTERFACE     | VRAM    | FP64 FMA (TFLOPS) | TDP (W) | PRICE (\~eBay) | NOTES                           |
| ---------------------------- | ------------- | --------|------------------ | ------- | -------------- | ------------------------------- |
| NVidia H100 (Hopper)[^tesla] | SXM5          | 80GB    | 25.6              | 350     | 💰💰           | Adapter board: ~$1100 on eBay   |
| NVidia A100 (Ampere)[^tesla] | SXM4          | 40/80GB | 9.7               | 250     | \~$1200        | Adapter board: ~$650 on eBay    |
| NVidia V100 (Volta)[^tesla]  | SXM2 and SXM3 | 16/32GB | 7.0               | 250     | \~$200/\~$350  | Adapter board: ~$300 on eBay    |


## BF16 Compatible

[BF16/BFloat16 (brain float)](https://en.wikipedia.org/wiki/Bfloat16_floating-point_format#bfloat16_floating-point_format) is a variation of FP16. It's notable for having the same exponent width as FP32. This is potentially handy because converting between BF16 and FP32 (as well as TF32) should only require adding or removing the bottom two bytes of the fraction.


## Other Compute Devices

* AMD BC-250 - A PlayStation 5 on a mini blade server
  * <https://pastebin.com/KPGGuSzx>
  * <https://www.phoronix.com/news/AMD-RADV-PS5-BC-250>
  * <https://www.techpowerup.com/forums/threads/omg.329796/>
  * <https://www.reddit.com/r/LocalLLaMA/comments/1f6hjwf/battle_of_the_cheap_gpus_lllama_31_8b_gguf_vs/>
* M4 Mac Pro
*


## Mining GPUs

Theses are specialty created (crippled) for cryptocurrency miners. These GPUs are e-waste now, but some might be .

<https://www.techpowerup.com/gpu-specs/?generation=Mining+GPUs&sort=generation>


### CMP 170HX

* <https://niconiconi.neocities.org/tech-notes/nvidia-cmp-170hx-review/>


### CMP 100-210, a 16 GB NVidia Volta GPU?

From an [eBay listing](https://www.ebay.ca/itm/156105331038), I discovered this strange mining card sold directly to miners.

> **Nvidia CMP 100-210 12GB Mining GPU (V100 VBIOS)**

Whoa whoa what? These can be flashed back into V100 GPUs? They also exhibit the strange 16 GB -> 12 GB HBM nerf? TELL ME MORE!

> Units from this listing are all guaranteed to have the **V100 VBIOS**, which users have reported to have slightly higher performance than the CMP bios revision.
>
> This is a relatively obscure Nvidia mining GPU that was only sold direct to miners. It shares the same GV100 and HBM memory as a Titan V, and will mine as well as a Titan V. It is also roughly equivalent to an Nvidia 100HX. About 80MH ETH back in the day.

Wow! This sounds too good to be true!

> So basically a reasonably powerful mining GPU that’s firmware locked and *physically modified to reduce the PCI express bandwidth to 1x 1.0 speeds.

Ah, there it is. There's the catch.

Still, the impression I get is that the CUDA cores actually work here.

> Also useful for local LLM processing, as long as the model fits entirely in VRAM due to the highly constrained PCI-E bus.
>
> ~60 Tokens/S in Mistral/Llama 7B Q4 (see pics)
> ~75 Tokens/S in Phi2 3B Q8 (see pics)
>
> Tested on Ubuntu with an i5-7400, which is likely still bottlenecking it.

The pictures do appear to be of LMStudio. I just need to check if those token rates match a V100.

On the surface, the CMP 100-210 looks like it might make a cheap V100. The fact that it can run the V100 BIOS is really interesting.

#### Questions

* Can the PCIe bus speed be fixed?
  * Can flashing the V100 BIOS and adding components help it achieve PCIe 3.0 and/or `x16` speeds?
* Do the V100's FP64 instructions work?
  * If so, that would make this the cheapest high FP64 throughput GPU
* What is the "HBM nerf" thah affects V100 GPUs? Why do some of these 16 GB cards report 12 GB?

#### Discussion

* <https://www.techpowerup.com/forums/threads/nvidia-cmp-100-210-or-100hx-gv100-gpu.321074/>


## Architecture

* <https://images.nvidia.com/aem-dam/Solutions/geforce/ada/nvidia-ada-gpu-architecture.pdf>
