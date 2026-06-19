{{flutter_js}}
{{flutter_build_config}}

(function () {
  function setProgress(percent) {
    if (typeof window.setFlutterSplashProgress === 'function') {
      window.setFlutterSplashProgress(percent);
    }
  }

  setProgress(0);

  _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      setProgress(40);

      const appRunner = await engineInitializer.initializeEngine();
      setProgress(70);

      await appRunner.runApp();
    },
  });
})();
