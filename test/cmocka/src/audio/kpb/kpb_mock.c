// SPDX-License-Identifier: BSD-3-Clause
//
// Copyright(c) 2019 Intel Corporation. All rights reserved.
//
// Author: Marcin Rajwa <marcin.rajwa@linux.intel.com>

#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <stdint.h>
#include <cmocka.h>

#include <sof/alloc.h>
#include <sof/notifier.h>
#include <sof/audio/component.h>
#include <mock_trace.h>
#include <sof/clk.h>

TRACE_IMPL()

void *rballoc(int zone, uint32_t caps, size_t bytes)
{
	(void)zone;
	(void)caps;

	return malloc(bytes);
}

void *rzalloc(int zone, uint32_t caps, size_t bytes)
{
	(void)zone;
	(void)caps;

	return calloc(bytes, 1);
}

void rfree(void *ptr)
{
	free(ptr);
}

void *_brealloc(void *ptr, int zone, uint32_t caps, size_t bytes)
{
	(void)zone;
	(void)caps;

	return realloc(ptr, bytes);
}

void pipeline_xrun(struct pipeline *p, struct comp_dev *dev, int32_t bytes)
{
}

int comp_set_state(struct comp_dev *dev, int cmd)
{
	return 0;
}

void notifier_register(struct notifier *notifier)
{
}

void notifier_unregister(struct notifier *notifier)
{
}

int schedule_task_init(struct task *task, uint16_t type, uint16_t priority,
		       uint64_t (*func)(void *data), void *data, uint16_t core,
		       uint32_t xflags)
{
	return 0;
}

void schedule_task(struct task *task, uint64_t start, uint64_t deadline,
		   uint32_t flags)
{
}

void __panic(uint32_t p, char *filename, uint32_t linenum)
{
	(void)p;
	(void)filename;
	(void)linenum;
}

uint64_t platform_timer_get(struct timer *timer)
{
	(void)timer;

	return 0;
}

uint64_t clock_ms_to_ticks(int clock, uint64_t ms)
{
	(void)clock;
	(void)ms;

	return 0;
}
