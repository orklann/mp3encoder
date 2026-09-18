#include <lame/lame.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void hello(void) {
    printf("Hello!\n");
}

typedef struct {
    lame_t lame;
    FILE *out;
    unsigned char *mp3_buffer;
    int mp3_buffer_size;
} Mp3Encoder;

int mp3_encoder_start(
    Mp3Encoder *encoder,
    const char *output_path,
    unsigned int sample_rate
) {
    encoder->lame = lame_init();
    if (!encoder->lame)
        return -1;

    lame_set_in_samplerate(encoder->lame, sample_rate);
    lame_set_num_channels(encoder->lame, 2);
    lame_set_brate(encoder->lame, 192);
    lame_set_quality(encoder->lame, 0);

    if (lame_init_params(encoder->lame) < 0) {
        lame_close(encoder->lame);
        return -2;
    }

    encoder->out = fopen(output_path, "wb");
    if (!encoder->out) {
        lame_close(encoder->lame);
        return -3;
    }

    // Large enough for a PCM chunk.
    encoder->mp3_buffer_size = 1.25 * 8192 + 7200;

    encoder->mp3_buffer =
        malloc(encoder->mp3_buffer_size);

    if (!encoder->mp3_buffer) {
        fclose(encoder->out);
        lame_close(encoder->lame);
        return -4;
    }

    return 0;
}


int mp3_encoder_write_pcm(
    Mp3Encoder *encoder,
    const int16_t *pcm,
    size_t frames
) {
    int encoded = lame_encode_buffer_interleaved(
        encoder->lame,
        (short *)pcm,
        (int)frames,
        encoder->mp3_buffer,
        encoder->mp3_buffer_size
    );

    if (encoded < 0)
        return -1;

    if (encoded > 0) {
        size_t written = fwrite(
            encoder->mp3_buffer,
            1,
            encoded,
            encoder->out
        );

        if (written != (size_t)encoded)
            return -2;
    }

    return 0;
}


int mp3_encoder_stop(Mp3Encoder *encoder)
{
    // IMPORTANT:
    // Flush LAME's internal buffers.
    int encoded = lame_encode_flush(
        encoder->lame,
        encoder->mp3_buffer,
        encoder->mp3_buffer_size
    );

    if (encoded < 0) {
        free(encoder->mp3_buffer);
        fclose(encoder->out);
        lame_close(encoder->lame);
        return -1;
    }

    if (encoded > 0) {
        fwrite(
            encoder->mp3_buffer,
            1,
            encoded,
            encoder->out
        );
    }

    fflush(encoder->out);

    free(encoder->mp3_buffer);
    fclose(encoder->out);
    lame_close(encoder->lame);

    encoder->mp3_buffer = NULL;
    encoder->out = NULL;
    encoder->lame = NULL;

    return 0;
}

Mp3Encoder encoder;

int start_pcm_to_mp3(const char *mp3_path, unsigned int sample_rate) {
    if (mp3_encoder_start(
        &encoder,
        mp3_path,
        sample_rate
    ) != 0) {
        return 1;
    } 
    return 0;
}

int write_pcm_to_mp3(int16_t *pcm, unsigned int frames) {
    return mp3_encoder_write_pcm(
            &encoder,
            pcm,
            frames);
}

void stop_pcm_to_mp3(void) {
    mp3_encoder_stop(&encoder);
}

