<template>
  <div class="px-0 px-md-5 py-4 d-flex flex-justify-center">
    <div class="col-12 col-md-6 col-lg-4 mt-8">
      <div class="p-4 panel-background border rounded-1 d-flex flex-column">
        <h3 class="mb-4 px-4 px-md-0">Setup Proxy</h3>
        <div>
          Create proxy contract to manage liquidity on Balancer. This is a
          one-time action and will save you gas in the long-term.
        </div>
        <div class="mt-4 d-flex flex-justify-center">
          <UiButton
            @click="setup()"
            v-if="!isInstanceReady"
            :loading="loading"
            :disabled="loading"
            class="button-primary"
          >
            Setup
          </UiButton>
          <UiButton @click="goBack()" v-else>Next</UiButton>
        </div>
        <div class="mt-2" v-if="loading">
          Waiting for confirmations to protect from chain reorganizations:
          {{ confirmations }}/10
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  data() {
    return {
      loading: false,
      confirmations: 0
    };
  },
  methods: {
    ...mapActions(['createProxy']),
    async setup() {
      this.loading = true;
      const tx = await this.createProxy();
      if (!tx) {
        this.loading = false;
        return;
      }
      for (let i = 0; i < 10; i++) {
        await tx.wait(i);
        this.confirmations++;
      }
      this.loading = false;
    },
    goBack() {
      this.$router.back();
    }
  },
  computed: {
    isInstanceReady() {
      return this.hasProxy && !this.loading;
    }
  }
};
</script>
