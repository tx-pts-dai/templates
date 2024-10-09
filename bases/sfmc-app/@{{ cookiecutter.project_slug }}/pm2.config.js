module.exports = {
   apps: [
      {
         name: "@{{ cookiecutter.service_name }} }}",
         script: "main.js",
         instances: 1,
         autorestart: true,
         watch: false,
         exec_mode: "fork",
         max_memory_restart: "1G",
         env: {
            NODE_ENV: "production",
         },
      },
   ],
}
