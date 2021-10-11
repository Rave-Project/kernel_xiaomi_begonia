/*
 * Copyright (c) 2017 MediaTek Inc.
 * Author: Yunfei Dong <yunfei.dong@mediatek.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef MTK_VCODEC_MEM_H
#define MTK_VCODEC_MEM_H

#include <media/videobuf2-dma-contig.h>
#include <uapi/linux/mtk_vcu_controls.h>
#include <linux/slab.h>
#include <asm/cacheflush.h>
#include <linux/mm.h>
#include <linux/dma-mapping.h>

#ifndef CONFIG_ARM64
#include "mm/dma.h"
#endif

#ifndef dmac_map_area
#define dmac_map_area __dma_map_area
#endif
#ifndef dmac_unmap_area
#define dmac_unmap_area __dma_unmap_area
#endif
#ifndef dmac_flush_range
#define dmac_flush_range __dma_flush_range
#endif

#define CODEC_MAX_BUFFER 512U
#define CODEC_ALLOCATE_MAX_BUFFER_SIZE 0x8000000UL /*128MB*/

/**
 * struct mtk_vcu_mem - memory buffer allocated in kernel
 *
 * @mem_priv:   vb2_dc_buf
 * @size:       allocated buffer size
 */
struct mtk_vcu_mem {
	void *mem_priv;
	size_t size;
};

/**
 * struct mtk_vcu_queue - the allocated buffer queue
 *
 * @vcu:        struct mtk_vcu
 * @mmap_lock:  the lock to protect allocated buffer
 * @dev:        device
 * @num_buffers:        allocated buffer number
 * @mem_ops:    the file operation of memory allocated
 * @bufs:       store the information of allocated buffers
 */
struct mtk_vcu_queue {
	void *vcu;
	struct mutex mmap_lock;
	struct device *dev;
	unsigned int num_buffers;
	const struct vb2_mem_ops *mem_ops;
	struct mtk_vcu_mem bufs[CODEC_MAX_BUFFER];
	int map_buf;
	int map_type;
};

#endif

