# Mux Volume Pipeline
#
#  Low Latency Playback with mux and volume.
#
# Pipeline Endpoints for connection are :-
#
#	Playback mux
#	B2 (DAI buffer)
#
#
#  host PCM_P -- B0 --> volume -- B1 --> mux(M) -- B2 --> sink DAI0
#                                              |
#                                              pipeline n+1 --> DAI
#

# Include topology builder
include(`utils.m4')
include(`buffer.m4')
include(`pcm.m4')
include(`pga.m4')
include(`muxdemux.m4')
include(`mixercontrol.m4')
include(`bytecontrol.m4')
include(`enumcontrol.m4')

# demux Bytes control with max value of 255
C_CONTROLBYTES(concat(`MUX', PIPELINE_ID), PIPELINE_ID,
	CONTROLBYTES_OPS(bytes, 258 binds the mixer control to bytes get/put handlers, 258, 258),
	CONTROLBYTES_EXTOPS(258 binds the mixer control to bytes get/put handlers, 258, 258),
	, , ,
	CONTROLBYTES_MAX(, 304),
	,	concat(`mux_priv_', PIPELINE_ID))


CONTROLENUM_LIST(channel_enums_1, LIST(`  ', `"off"', `"L1"', `"R1"', `"L2"', `"R2"'))

# Demux enum control
C_CONTROLENUM(mux_control_1, PIPELINE_ID,
	channel_enums_1,
	LIST(`  ', ENUM_CHANNEL(FL, 3, 0), ENUM_CHANNEL(FR, 3, 1)),
	CONTROLENUM_OPS(enum,
	257 binds the mixer control to enum get/put handlers,
	257, 257))

# Volume Mixer control with max value of 32
C_CONTROLMIXER(Master Playback Volume, PIPELINE_ID,
	CONTROLMIXER_OPS(volsw, 256 binds the mixer control to volume get/put handlers, 256, 256),
	CONTROLMIXER_MAX(, 32),
	false,
	CONTROLMIXER_TLV(TLV 32 steps from -64dB to 0dB for 2dB, vtlv_m64s2),
	Channel register and shift for Front Left/Right,
	LIST(`	', KCONTROL_CHANNEL(FL, 1, 0), KCONTROL_CHANNEL(FR, 1, 1)))

#
# Volume configuration
#

W_VENDORTUPLES(playback_pga_tokens, sof_volume_tokens,
LIST(`		', `SOF_TKN_VOLUME_RAMP_STEP_TYPE	"0"'
     `		', `SOF_TKN_VOLUME_RAMP_STEP_MS		"250"'))

W_DATA(playback_pga_conf, playback_pga_tokens)

#
# Components and Buffers
#

# Host "Low latency Playback" PCM
# with 2 sink and 0 source periods
W_PCM_PLAYBACK(PCM_ID, Low Latency Playback, 2, 0, SCHEDULE_CORE)

# "Master Playback Volume" has 2 source and x sink periods for DAI ping-pong
W_PGA(1, PIPELINE_FORMAT, DAI_PERIODS, 2, playback_pga_conf, SCHEDULE_CORE,
	LIST(`		', "PIPELINE_ID Master Playback Volume"))

# Mux 0 has 2 sink and source periods.
W_MUXDEMUX(0, 0, PIPELINE_FORMAT, 2, 2, SCHEDULE_CORE,
	LIST(`         ', concat(`MUX', PIPELINE_ID)),
	LIST(`         ', "mux_control_1"))

# Low Latency Buffers
W_BUFFER(0, COMP_BUFFER_SIZE(2,
	COMP_SAMPLE_SIZE(PIPELINE_FORMAT), PIPELINE_CHANNELS, COMP_PERIOD_FRAMES(PCM_MAX_RATE, SCHEDULE_PERIOD)),
	PLATFORM_HOST_MEM_CAP)
W_BUFFER(1, COMP_BUFFER_SIZE(2,
	COMP_SAMPLE_SIZE(PIPELINE_FORMAT), PIPELINE_CHANNELS, COMP_PERIOD_FRAMES(PCM_MAX_RATE, SCHEDULE_PERIOD)),
	PLATFORM_COMP_MEM_CAP)
W_BUFFER(2, COMP_BUFFER_SIZE(DAI_PERIODS,
	COMP_SAMPLE_SIZE(PIPELINE_FORMAT), PIPELINE_CHANNELS, COMP_PERIOD_FRAMES(PCM_MAX_RATE, SCHEDULE_PERIOD)),
	PLATFORM_DAI_MEM_CAP)

#
# Pipeline Graph
#
#  host PCM_P --B0--> Demux --B1--> volume ---B2--> sink DAI0

P_GRAPH(pipe-ll-playback-PIPELINE_ID, PIPELINE_ID,
	LIST(`		',
	`dapm(N_BUFFER(0), N_PCMP(PCM_ID))',
	`dapm(N_PGA(1), N_BUFFER(0))',
	`dapm(N_BUFFER(1), N_PGA(1))',
	`dapm(N_MUXDEMUX(0), N_BUFFER(1))',
	`dapm(N_BUFFER(2), N_MUXDEMUX(0))'))
#
# Pipeline Source and Sinks
#
indir(`define', concat(`PIPELINE_SOURCE_', PIPELINE_ID), N_BUFFER(2))
indir(`define', concat(`PIPELINE_MUX_', PIPELINE_ID), N_MUXDEMUX(0))
indir(`define', concat(`PIPELINE_PCM_', PIPELINE_ID), Low Latency Playback PCM_ID)

#
# PCM Configuration
#


# PCM capabilities supported by FW
PCM_CAPABILITIES(Low Latency Playback PCM_ID, CAPABILITY_FORMAT_NAME(PIPELINE_FORMAT), 48000, 48000, 2, PIPELINE_CHANNELS, 2, 16, 192, 16384, 65536, 65536)

