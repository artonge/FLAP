/// <reference types='codeceptjs' />

type steps_file = typeof import('./steps_file.js');
type settingsPage = typeof import('./pages/settings');

declare namespace CodeceptJS {
  interface SupportObject { I: I, current: any, settingsPage: settingsPage }
  interface Methods extends Puppeteer {}
  interface I extends ReturnType<steps_file> {}
  namespace Translation {
    interface Actions {}
  }
}
