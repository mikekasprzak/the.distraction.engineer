+++
title = "Dell T7920"
draft = true
+++



## Memory

[Double Data Rate](https://en.wikipedia.org/wiki/Double_data_rate) (DDR) memory moves data on both the rising and falling edge of a clock signal. This is why memory if often rated in "Mega Transfers" instead of "Mega Hertz", as there are 2 "transfers" per clock tick (Hz). DDR4-3200 memory operates at 1600 MHz on the bus, with an effective trasfer rate of 3200 MT/s.

PC (Pipeline Clock? Personal Computer?) is a theoretical measure of bandwidth, in bits. PC4-25600 (DDR4-3200) memory can _theoretically_ push 25.6 GigaBits of data, or 3.2 Gigabytes.

DDR memory uses a **64 bit** data bus (72 bit with ECC). This is counter-intuative, but the multiplier (i.e. x4) is the number of bits of data provided per chip, meaning a "x4" memory stick uses 16 chips to provide a 64bit bus (18 chips with ECC). Similarly a "x8" uses only 8 chips (9 with ECC).

Single/Dual/Quad rank are the number of sets of chips on the memory, so a Dual Rank has 2 sets.

* 1Rx8 -- Single Rank x8 -- 8 chips
* 1Rx4 -- Single Rank x4 -- 16 chips
* 2Rx8 -- Dual Rank x8 -- 16 chips
* 2Rx4 -- Dual Rank x4 -- 32 chips
* 4Rx8 -- Quad Rank x8 -- 32 chips
* 4Rx4 -- Quad Rank x4 -- 64 chips

DDR clock rates have varried over the generations. DDR2 uses a x2 multiplier, DDR3 and DDR4 a x4 multplier, and DDR5 (and DDR1) don't use a multiplier.

* <https://en.wikipedia.org/wiki/Synchronous_dynamic_random-access_memory#PREFETCH>


### DDR vs GDDR

Modern DDR memory chips come in 4bit and 8bit variations, corrisponding to the x4 and x8 noted by DDR Memory Modules. Multiple chips are used to make DDR Memory Modules (i.e. RAM sticks).

GDDR memory chips provide 2-4 channels of 16bit data. Modern GDDR memory chips come in x32 (32bit bus or 2x 16bit) and x64 (64bit bus or 4x 16bit) variations. A single x32 chip can be run standalone (x16 mode) or paired with a 2nd x32 chip (x8 mode) to provide the same 64bit data bus as the x64 chips.

DDR Memory Modules have a 64bit bus, with only a single channel. A GDDR x64 chip (or two x32 chips) also has a 64bit bus, but the bus is broken up into 4 channels. This means the data rate of an equivalently clocked DDR Memory Module and GDDR x64 chip are the same, but 4 different 16bit chunks of data can be read with GDDR, while only a single linear 64bit chunk is read from a DDR Module.

A high performance GPU will often have multiple x64 chips (or x32 pairs), enabling data busses of 128bits, 256bits, and beyond.

The GDDR6 specification supports up to 1GB per x32 chip (BGA 180 package) or 2GB per x64 chip (BGA 460 package).


### DDR4 RDIMM and LRDIMM options
RAM Latency Calculator: <https://notkyon.moe/ram-latency2.htm>

* SK Hynix 16GB DDR4-3200 RDIMM 2Rx8 -- HMA82GR7CJR8N-XN -- [CAS-22](https://memory.net/product/hma82gr7cjr8n-xn-sk-hynix-1x-16gb-ddr4-3200-rdimm-pc4-25600r-dual-rank-x8-module/) (13.75 ns @ 3200, 15 ns @ 2933, **16.5 ns** @ 2666): ~$20 USD **
* SK Hynix 16GB DDR4-2666 RDIMM 2Rx4 -- HMA42GR7BJR4N-VK -- [CAS-19](https://www.serversupply.com/MEMORY/PC4-21300/16GB/HYNIX/HMA42GR7BJR4N-VK_295626.htm) (**14.25 ns** @ 2666): ~$15 USD
* SK Hynix 16GB DDR4-2666 RDIMM 2Rx8 -- HMA82GR7CJR8N-VK -- [CAS-19](https://memory.net/product/hma82gr7cjr8n-vk-sk-hynix-1x-16gb-ddr4-2666-rdimm-pc4-21300v-r-dual-rank-x8-module/): ~$18
* Samsung 64GB DDR4-2666 LRDIMM 4Rx4 -- M386A8K40CM2-CTD -- [CAS-19](https://memory.net/product/m386a8k40cm2-ctd-samsung-1x-64gb-ddr4-2666-lrdimm-pc4-21300v-l-quad-rank-x4-module/) (**14.25 ns** @ 2666)






### DDR4 Optane memory options



* Intel Optane 100 Series 128GB DDR4-2666 DCPMM -- NMA1XXD128GPS/GQS -- ~$50 USD (low ~$30)
* Intel Optane 100 Series 256GB DDR4-2666 DCPMM -- NMA1XXD256GPS/GQS -- ~$135 USD (low ~$90)
* Intel Optane 100 Series 512GB DDR4-2666 DCPMM -- NMA1XXD512GPS/GQS -- ~$400 USD (low ~$200)
* Intel Optane 200 Series 128GB DDR4-3200 DCPMM -- NMB1XXD128GPS -- ~$50 USD
* Intel Optane 200 Series 256GB DDR4-3200 DCPMM -- NMB1XXD256GPS -- ~$275 USD
