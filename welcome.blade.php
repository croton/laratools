<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>?1</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,600" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.5/css/bulma.min.css">
    <script defer src="https://use.fontawesome.com/releases/v5.3.1/js/all.js"></script>
  </head>
  <body>
    <section class="section">
      @if (Route::has('login'))
        <div class="top-right links">
          @auth
            <a href="{{ url('/home') }}">Home</a>
          @else
            <a href="{{ route('login') }}">Login</a>

            @if (Route::has('register'))
              <a href="{{ route('register') }}">Register</a>
            @endif
          @endauth
        </div>
      @endif

      <div class="container">
        <h1 class="title">
          ?1
        </h1>
        <p class="subtitle">
          Welcome to <strong>?1</strong>!
        </p>
      </div>
    </section>
  </body>
</html>
