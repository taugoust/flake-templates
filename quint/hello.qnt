module hello {
  // Quint describes states and transitions rather than printing to stdout.
  var greeting: str

  action init = greeting' = "Hello"
  action step = greeting' = "Hello, world!"

  val validGreeting = Set("Hello", "Hello, world!").contains(greeting)
}
