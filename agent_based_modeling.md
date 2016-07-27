
# Random initialization


```python
import random
size = 20
numXs = 10
numOs = size-numXs
world = []
world.extend( [0]*numOs )
world.extend( [1]*numXs )
random.shuffle(world)
print(world)
```

    [0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1]


# Prettier printing


```python
def world_as_string(world):
    '''Create a string representation
    of object `world` using #s and Os'''
    output = ''
    for slot in world:
        if slot == 0:
            output += 'O'
        else:
            output += '#'
    return(output)

print(world_as_string(world))
```

    O#OOO#OO######OOOO##


# Proportion of like neighbors


```python
def proportion_same(i,world,distance=2):
    '''Given a world object and an index `i`, return
    the proportion of world[i]'s neighbors that are
    the same type as world[i] itself.'''

    neighbors = []

    # get left neighbors
    leftIndex = max(0,i-distance)
    neighbors += world[leftIndex:i]

    # get right neighbors
    rightIndex = min(len(world),i+distance+1)
    neighbors += world[i+1:rightIndex]

    num1s = sum(neighbors)
    num0s = len(neighbors) - num1s

    if world[i]==0:
        return( float(num0s)/(num0s+num1s) )
    elif world[i]==1:
        return( float(num1s)/(num0s+num1s) ) 
```

# Unhappy agents


```python
def unhappy_agents(world,threshold=.5,distance=2):
    '''Return a list of indices i for which less than
    `threshold` of world[i]'s neighbors are of the same
    type as world[i] itself'''

    unhappy = []
    for i in range(len(world)):
        if proportion_same(i,world,distance) < threshold:
            unhappy.append(i)
    return(unhappy)
```

# Random move


```python
def randomMove(i,world):
    '''move item at index `i` in `world` to a
    random (possibly identical) index'''

    agent = world.pop(i)
    insertAt = random.randint(0,len(world))
    world.insert(insertAt,agent)
```

# Putting it together


```python
# parameters
threshold = 0.5
nbhd_distance = 5
size = 40
numXs = 20

numOs = size-numXs
world = []
world.extend( [0]*numOs )
world.extend( [1]*numXs )
random.shuffle(world)

while unhappy_agents(world,threshold,nbhd_distance):
    # get list of unhappy agents:
    cur_unhappy = unhappy_agents(world,threshold,nbhd_distance)
    # pick one at random:
    index = random.choice(cur_unhappy)
    # move that agent to a new slot:
    randomMove(index,world)
    print(world_as_string(world))
```

    O#OOO#OO#OO####O#O#####OOOOOO#O###O#OO##
    O#OOOO#OO#OO####O#O#####OOOOOO#O####OO##
    O#OO#OO#OO#OO####O#O####OOOOOO#O####OO##
    O#OO#OO#OO#OOO####O#O####OOOOOO#O####O##
    O#OO#OOOO##OOO####O#O####OOOOOO#O####O##
    O#OOO#OOOO##OOO####O#O####OOOOOO#O######
    O#OOOO#OOOO##OO####O#O####OOOOOO#O######
    OOOOO#OOOO##OO####O#O#####OOOOOO#O######
    OOOOOO#OOOO##OO#####O#####OOOOOO#O######
    OOOOOO#OOOO#OO#####O#####OOO#OOO#O######
    OOOOOOOOOO#OO#####O#####OOO#O#OO#O######
    OOOOOOOOOO#OO#####O######OOOO#OO#O######
    OOOO#OOOOOOOO#####O######OOOO#OO#O######
    OOOO#OOOOOOOO####O#######OOOO#OO#O######
    OOOOOOOO#OOOO####O#######OOOO#OO#O######
    OOOOOOOOOOOO####O#######OOOO#OO#O#######
    OOOOOOOOOOOO####O#######OOOO#OO#O#######
    OOOOOOOOOOOO####O###O####OOO#OO#O#######
    OOOOOOOOOOOO####O###O####OOO#OO#O#######
    OOOOOOOOOOOO#####O###O####OOOOO#O#######
    OOOOOOOOOOOO#####O###O####OOOOO######O##
    OOOOOOOOOOOO###O##O###O####OOOO######O##
    OOOOOOOOOOOOO###O##O###O####OOO######O##
    OOOOOOOOOOOOO###O##OO###O####OOO########
    OOOOOOOOOOOOOO###O##O###O####OOO########
    OOOOOOOOOOOOOOO###O##O#######OOO########
    OOOOOOOOOOOOOOOO#####O#######OOO########
    OOOOOOOOOOOOOOOOO#####O#######OO########
    OOOOOOOOOOOOOOOOOO#####O#######O########
    OOOOOOOOOOOOOOOOOO############OO########
    OOOOOOOOOOOOOOOOOO#########O###O########
    OOOOOOOOOOOOOOOOOO#######O##O###########
    OOOOOOOOOOOOOOOOOOO#########O###########
    OOOOOOOOOOOOOOOOOOO###O#################
    OOOOOOOOOOO#OOOOOOOO##O#################
    OOOOOOOOOOOO#OOOOOOOO###################
    OOOO#OOOOOOOOOOOOOOOO###################
    OOOOOOOOOOOOOOOOOOOO####################



```python

```
