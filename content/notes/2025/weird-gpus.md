+++
title = "Weird GPUs"
date = "2025-02-17T18:02:06.119Z"
summary = "This notebook collect information about atypical GPUs, and how they compare to more widely available consumer GPUs, with a focus on compute"
keywords = [ ]
tags = [ "amd", "cuda", "intel", "nvidia", "opencl", "rocm", "sycl" ]
categories = [ "compute", "gpu" ]
+++

## GPU Overview


### Throughput (in TFLOPS/TOPS)

| GENERATION | GPU              | INTERFACE    | VRAM          | NVLINK | FP64   | FP32   | INT32  | FP16  | BF16  | TF32  |
| ---------- | ---------------- | ------------ | ------------- | ------ | ------ | ------ | ------ | ----- | ----- | ----- |
| Blackwell  | Tesla B100       | SXM6         | 192 GB HBM3e  | YES    | -      | -      | -      | -     | -     | 989   |
| Blackwell  | GeForce RTX 50xx | PCIe 5.0 x16 | 32 GB GDDR7   | -      | 1.64   | 105    | 105    | 105   | 105   | 105   |
| Hopper     | Tesla H100       | SXM5         | 80 GB HBM3    | YES    | 34.0   | 67     | 34     | 120   | 120   | 454   |
| Ada        | GeForce RTX 40xx | PCIe 4.0 x16 | 24 GB GDDR6X  | -      | 0.53   | 83     | 83     | 83    | 83    | 83    |
| Ampere     | Tesla A100       | PCIe 4.0 x16 | 40/80 GB HBM2 | YES    | 9.7    | 19.5   | 19.5   | 78    | 78    | 156   |
| Ampere     | GeForce RTX 30xx | PCIe 4.0 x16 | 24 GB         | YES    | 0.62   | 40     | 20\*   | 40    | 40    | 40    |
| Turing     | Titan RTX        | PCIe 3.0 x16 | 24 GB GDDR6   | YES    | 0.51   | 16.3\* | 16.3\* | 32.6  | -     | -     |
| Turing     | GeForce RTX 20xx | PCIe 3.0 x16 | 11 GB GDDR6   | YES    | 0.42   | 14.2\* | 14.2\* | 28.5  | -     | -     |
| Volta      | Tesla V100       | PCIe 3.0 x16 | 32 GB HBM2    | YES    | 7.8    | 15.7\* | 15.7\* | 31.4  | -     | -     |
| Volta      | CMP 100-210      | PCIe 1.0 x1  | 16 GB HBM2    | -      | ?      | ?      | ?      | ?     | -     | -     |
| Pascal     | Tesla P100       | PCIe 3.0 x16 | 16 GB HBM2    | YES    | 4.5    | 8.7    | -      | 21.2  | -     | -     |

* Volta and Turing GPUs can execute FP32 and INT32 operations simultaneously
* Ampere GPUs have dedicated FP32 cores and hybrid FP32/INT32 cores


### Tensor Operation Througput (in TFLOPS/TOPS)

| GENERATION | GPU              | FP8/FP4     | INT8/INT4    | FP16/BF16/FP8/FP4 +FP32 | FP16/FP8/FP4 +FP16 | +FP64 | NOTES         |
| ---------- | ---------------- | ----------- | ------------ | ----------------------- | ------------------ | ----- | ------------- |
| Blackwell  | Tesla B100       | (3500/7000) | (3500/-)     | 1980/1980/3500/7000     | 1980/3500/7000     | 30    | FP6, NO INT4  |
| Blackwell  | GeForce RTX 50xx | (838/1676)  | (838/-)      | 210/210/419/1676        | 419/838/1676       | -     | NO INT4       |
| Hopper     | Tesla H100       | (1979/-)    | (1979/-)     | 990/990/1979/-          | 990/1979/-         | 67    | NO INT4       |
| Ada        | GeForce RTX 40xx | (660/-)     | (660/1321)   | 165/165/660/-           | 330/660/-          | -     |               |
| Ampere     | Tesla A100       | -           | (624/1248)   | 312/312/-/-             | 624/-/-            | 19.5  | BINARY (INT1) |
| Ampere     | GeForce RTX 30xx | -           | (320/640)    | 80/80/-/-               | 160/-/-            | -     | BINARY (INT1) |
| Turing     | Titan RTX        | -           | (261/522)    | 130/-/-/-               | 130/-/-            | -     |               |
| Turing     | GeForce RTX 20xx | -           | (228/455)    | 57/-/-/-                | 114/-/-            | -     |               |
| Volta      | Tesla V100       | -           | (62)         | 125/-/-/-               | 125/-/-            | -     |               |
| Pascal     | Tesla P100       | -           | -            | -                       | -                  | -     |               |


* Blackwell (50xx) Architecture: <https://images.nvidia.com/aem-dam/Solutions/geforce/blackwell/nvidia-rtx-blackwell-gpu-architecture.pdf>
* Ada (40xx) Architecture: <https://images.nvidia.com/aem-dam/Solutions/Data-Center/l4/nvidia-ada-gpu-architecture-whitepaper-v2.1.pdf>
* Hopper (H100) Architecture: <https://www.advancedclustering.com/wp-content/uploads/2022/03/gtc22-whitepaper-hopper.pdf>
* Ampere (A100) Architecture: <https://images.nvidia.com/aem-dam/en-zz/Solutions/data-center/nvidia-ampere-architecture-whitepaper.pdf>
* Ampere (30xx) Architecture: <https://www.nvidia.com/content/PDF/nvidia-ampere-ga-102-gpu-architecture-whitepaper-v2.pdf>
* Turing (20xx) Architecture: <https://images.nvidia.com/aem-dam/en-zz/Solutions/design-visualization/technologies/turing-architecture/NVIDIA-Turing-Architecture-Whitepaper.pdf>
* Volta (V100) Architecture: <https://images.nvidia.com/content/volta-architecture/pdf/volta-architecture-whitepaper.pdf>
* Pascal (P100) Architecture: <https://images.nvidia.com/content/pdf/tesla/whitepaper/pascal-architecture-whitepaper.pdf>
* Tesla Datacenter GPU's on Wikipedia: <https://en.wikipedia.org/wiki/Nvidia_Tesla#Specifications>

* INT4 removed from hopper <https://arxiv.org/html/2402.13499v1>

## FP64 Workloads

Consumer GPUs tend to have poor 64bit floating point performance. That said, CPUs and GPUs are often "good enough" for most use cases. Unless you do simulation work, you don't likely need this.

| GPU                  | INTERFACE    | VRAM               | FP64  | +FP64 | TDP   | PRICE (\~eBay)         | NOTES                |
| -------------------- | ------------ | ------------------ |------ | ----- | ----- | ---------------------- | -------------------- |
| NVidia H100 (Hopper) | PCIe 4.0 x16 | 80 GB HBM3         | 25.6  | 67    | 350 W | 💰💰                   | SXM5 available       |
| NVidia A100 (Ampere) | PCIe 4.0 x16 | 40/80 GB HBM2      | 9.7   | 19.5  | 250 W | 💰 (\~$5000/~$??)      | SXM4 available       |
| NVidia V100 (Volta)  | PCIe 3.0 x16 | 12\*/16/32 GB HBM2 | 7.0   | -     | 250 W | \~$500/\~$650/\~$1800  | SXM2/SXM3 available  |
| NVidia CMP 100-210\* | PCIe 1.0 1x  | 12\*/16 GB HBM2    | ?     | -     | ?     | \~$200                 | V100                 |
| NVidia P100 (Pascal) | PCIe 3.0 x16 | 16 GB HBM2         | 5.3   | -     | 250 W | \~$250                 | SXM/SXM2 available   |

* The CMP 100-210 is a neutered V100. Testing is required but it may have working FP64 cores.
* Some 16 GB v100 cards on eBay are listed as "neutered" 12 GB cards


### SXM GPUs

Certain NVidia GPUs are also available as [SXM](https://en.wikipedia.org/wiki/SXM_(socket)), a proprietary NVidia interface. SXM can be adapted to PCIe with an adapter board.

| GPU                     | INTERFACE     | VRAM          | FP64  | +FP64 | TDP   | PRICE (\~eBay) | NOTES                         |
| ----------------------- | ------------- | --------------|------ | ----- | ----- | -------------- | ----------------------------- |
| NVidia B100 (Blackwell) | SXM6          | 192 GB HBM3e  | -     | 30    | 700 W | 💰💰💰         |                               |
| NVidia H100 (Hopper)    | SXM5          | 80 GB HBM3    | 25.6  | 67    | 700 W | 💰💰           | Adapter board: ~$1100 on eBay |
| NVidia A100 (Ampere)    | SXM4          | 40/80 GB HBM2 | 9.7   | 19.5  | 400 W | \~$1200/💰     | Adapter board: ~$650 on eBay  |
| NVidia V100 (Volta)     | SXM2/SXM3     | 16/32 GB HBM2 | 7.0   | -     | 350 W | \~$200/\~$350  | Adapter board: ~$300 on eBay  |
| NVidia P100 (Pascal)    | SXM2          | 16 GB HBM2    | 5.3   | -     | 300 W | \~$40          | Adapter board: ~$300 on eBay  |


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
