# Modelling how a virus spreads with Julia

## How it works
 
- The application starts by creating a specified number of healthy, infected and immune people.
- The application runs for a predetermined number of iterations, on each iteration...
  - Each person moves within the confines of the world grid.
  - The application checks to see if any healthy people are dangerously close to infected people.
  - If so, there is a probability that they too will become infected. 
  - There is a chance that infected people will die after a calculated number of iterations. 

All application settings are stored in the config.ini file and are described below.

## Application settings
- healthy: The number of healthy people when the application starts.
- infected: The number of infected people when the application starts.
- immune: The number of immune people when the application starts.
- healthy_radius: The area around a healthy person defines a risk of infection.
- infected_radius: The area around an infected person defines a risk of infection.
- probability: The % chance that a healthy person will become infected if they are close enough to an infected person.
- max_step: The maximum number of steps that a person will move in their primary direction.
- min_step: The maximum number of steps that a person will move in their secondary direction.
- chance_of_dying: The % chance that an infected person will die some time after becoming infected.
- min_death_steps: The minimum number of iterations before an infected person dies.
- max_death_steps: The maximum number of iterations before an infected person dies.

