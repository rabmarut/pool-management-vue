<template>
  <div>
    <UiLoading v-if="!pool.id" class="big py-4" />
    <UiTable style="border-top-left-radius: 0 !important;" v-else>
      <UiTableTh>
        <div v-text="'Token'" class="flex-auto text-left" />
        <div v-text="'Weight'" class="column" />
        <div v-text="'Pool Balance'" class="column hide-sm" />
        <div v-text="'My Pool Balance'" class="column hide-sm hide-md" />
        <div v-text="'My Asset Value'" class="column hide-sm hide-md hide-lg" />
      </UiTableTh>
      <ListTokens :pool="pool" />
    </UiTable>
  </div>
</template>

<script>
export default {
  props: ['pool']
};
</script>
