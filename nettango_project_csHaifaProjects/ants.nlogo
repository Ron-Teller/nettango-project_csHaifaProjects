extensions [import-a fetch]
;extensions [import-a profiler]

globals[
  minimum-separation
  max-separate-turn
  last-world-file-that-was-loaded
  radius-ant-searches-for-flockmates
  brush-in-draw-mode
  ant-walking-style
  display-pheromone-type
  brush-shape
  brush-type
  background-type-being-displayed
  local-background-image-file-path-chosen-by-user
  brush-type-icon
  brush-draw-erase-mode-icon
  brush-icon-size
  brush-icon-transparency-normalized
  min-who-number-of-ants-after-setup
  food-pheromone-color-rgb
  nest-pheromone-color-rgb
  amount-of-food-in-nests
  food-count-in-each-food-source
  show-pheromone?
  center-of-nests
  center-of-food-sources
  patches-occupied-by-food-sources
  -patches-with-barriers
  nests-information-gfx-overlay
  food-sources-information-gfx-overlay
  average-xy-coordinates-of-patches-occupied-by-food-sources
  food-source-numbers-used-so-far
  nest-source-numbers-used-so-far
  current-nest-displaying-pheromone
  -brush-border-outline
  -brush-cursor
  tick-count-when-brush-was-last-activated
  mouse-down?-when-brush-was-last-activated
  mousexy-when-brush-was-last-activated
  current-mousexy
  current-mouse-down?
  current-mouse-inside?
  patches-drawn-on-since-brush-was-held-down
  pheromone-drop-rate
  pheromone-diffusion-rate
  pheromone-evaporation-rate
  food-sniff-sensitivity-lower-threshold
  nest-sniff-sensitivity-lower-threshold
  pheromone-released-decrease-rate
  food-source-colors
  nest-source-colors
  spread-pheromones-every-number-of-ticks
]

patches-own [
  food-pheromone-list
  nest-pheromone-list
  tmp-food-pheromone-value
  tmp-nest-pheromone-value
  is-barrier
  amount-of-food
  food-source-number
  ;is-nest
  ;nest-source-number
  ;tmp-pheromone-list-used-for-diffuse
  ;pheromone-gfx
]

ants-own [
  home-nest-source-number
  food-pheromone-released
  nest-pheromone-released
  amount-of-food-carried
  pheromone-zero-clock
  ;leader
  ;nearest-neighbor
  ;flockmates
]

nests-own [
  source-number
]

;food-own [
;  source-number
;]

ant-markers-own [
  ant-being-marked
]

nest-information-gfx-overlay-own [
  nest-source-number-gfx-overlay
  food-count-gfx-overlay
  ant-count-gfx-overlay
]

food-information-gfx-overlay-own [
  food-source-number-gfx-overlay
  food-count-gfx-overlay
]

;breed [patch-pheromone-gfx a-patch-pheromone-gfx]
breed [food-information-gfx-overlay a-food-information-gfx-overlay]
breed [nest-information-gfx-overlay a-nest-information-gfx-overlay]
breed [nests nest]
;breed [food a-food]
breed [ants ant]
;breed [barriers barrier]
breed [ant-markers ant-marker]
breed [gfx-overlay a-gfx-overlay]
breed [brush-border-outlines brush-border-outline]
breed [brush-cursors brush-cursor]
;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ;todo clean up this code logic for reload, its messy
  let temp-last-world-file-that-was-loaded last-world-file-that-was-loaded
  let temp-background-image-file-path local-background-image-file-path-chosen-by-user
  let temp-background-type-being-displayed background-type-being-displayed
  clear-all
  reset-ticks
  set last-world-file-that-was-loaded temp-last-world-file-that-was-loaded
  set local-background-image-file-path-chosen-by-user temp-background-image-file-path
  set background-type-being-displayed temp-background-type-being-displayed
  setup-globals
  setup-patches
  ;set-background-image
  setup-brush
  ;create-world
  #blocks#create-world
  recolor-all-patches
  update-all-nest-information
  update-all-plots
end

to quick-fix-running-world-without-nests
end

to create-world
  setup-food
  setup-nests
  setup-ants
end

to set-background-image
  ifelse user-has-chosen-local-background-image [
    set-background-image-to-file-chosen-by-user ]
  [
    ifelse is-default-background-specified [
      set-background-image-to-default ]
    [
    ]
  ]
end

to-report is-empty-background-specified
  report background-type-being-displayed = "none"
end

to-report is-default-background-specified
  report background-type-being-displayed = "default"
end

to clear-background
  clear-drawing
end

to clear-ant-trails
  clear-drawing
  set-background-image
end

to remove-background-image
  clear-drawing
  set background-type-being-displayed "none"
end

to display-food-pheromone
  set display-pheromone-type "food"
  recolor-all-patches
end

to display-nest-pheromone
  set display-pheromone-type "nest"
  recolor-all-patches
end

to-report user-has-chosen-local-background-image
  report background-type-being-displayed = "local"
  ;report not (local-background-image-file-path-chosen-by-user = 0)
end

to set-background-image-to-file-chosen-by-user
  carefully [
    import-drawing local-background-image-file-path-chosen-by-user
    import-drawing local-background-image-file-path-chosen-by-user
    set background-type-being-displayed "local"
  ] []
end

to setup-brush
  set brush-in-draw-mode true
  set brush-shape "square"
  set brush-type "barrier"
  set brush-icon-size 4
  set brush-icon-transparency-normalized 0.8
  set tick-count-when-brush-was-last-activated 0
  create-brush-border-outlines 1 [hide-turtle set -brush-border-outline self]
  create-brush-cursors 1 [hide-turtle set -brush-cursor self]
  create-gfx-overlay 1 [set brush-type-icon self
    set color add-transparency red brush-icon-transparency-normalized
    setxy (max-pxcor - brush-icon-size - ((brush-icon-size - 1) * 0.5)) (max-pycor - ((brush-icon-size - 1) * 0.5))
    set size brush-icon-size]
  create-gfx-overlay 1 [set brush-draw-erase-mode-icon self
    set color add-transparency red brush-icon-transparency-normalized
    setxy (max-pxcor - ((brush-icon-size - 1) * 0.5)) (max-pycor - ((brush-icon-size - 1) * 0.5))
    set size brush-icon-size ]
  update-brush-cursor-icon
  update-brush-type-icon
  update-brush-add-erase-mode-icon
end

to update-brush-type-icon
  update-brush-type-icon-shape
  update-brush-type-icon-color
end

to update-brush-type-icon-shape
  ask brush-type-icon [set shape word "brush-type-icon-" brush-type]
end

to update-brush-type-icon-color
  ifelse brush-type = "barrier" [set-brush-type-icon-color barrier-color ]
  [
    ifelse brush-type = "trail" or brush-type = "mark" [set-brush-type-icon-color blue ]
    [
      ifelse brush-type = "nest" [set-brush-type-icon-color nest-source-number-color 0]
      [
        set-brush-type-icon-color red
      ]
    ]
  ]
end

to set-brush-type-icon-color [-color]
  ask brush-type-icon [set color add-transparency -color brush-icon-transparency-normalized]
end

to update-brush-add-erase-mode-icon
  ifelse is-brush-in-draw-mode [
    set-brush-draw-erase-icon-to-draw ]
  [
    set-brush-draw-erase-icon-to-erase ]
end

to-report add-transparency [-color transparency-normalized]
  report lput (transparency-normalized * 255) extract-rgb -color
end

to setup-globals
  update-pheromone-color-rgb
  set show-pheromone? true
  set food-count-in-each-food-source []
  set background-type-being-displayed ifelse-value background-type-being-displayed = 0 ["default"] [background-type-being-displayed]
  set pheromone-drop-rate 10
  set pheromone-diffusion-rate 0.4
  set pheromone-evaporation-rate 0.5
  set food-sniff-sensitivity-lower-threshold 0.02
  set nest-sniff-sensitivity-lower-threshold 0
  set pheromone-released-decrease-rate 1.45
  set display-pheromone-type "food"
  set ant-walking-style "zig-zag"
  set amount-of-food-in-nests []
  set center-of-nests []
  set center-of-food-sources []
  set nests-information-gfx-overlay []
  set food-sources-information-gfx-overlay []
  set minimum-separation 1
  set max-separate-turn 1.5
  set radius-ant-searches-for-flockmates 3
  set mouse-down?-when-brush-was-last-activated false
  set mousexy-when-brush-was-last-activated [ ]
  set patches-drawn-on-since-brush-was-held-down no-patches
  set current-mousexy (list mouse-xcor mouse-ycor)
  set current-mouse-down? mouse-down?
  set current-mouse-inside?  mouse-inside?
  set last-world-file-that-was-loaded ""
  set food-source-numbers-used-so-far []
  set nest-source-numbers-used-so-far []
  set patches-occupied-by-food-sources []
  set -patches-with-barriers no-patches
  set current-nest-displaying-pheromone 0
  set average-xy-coordinates-of-patches-occupied-by-food-sources []
  set spread-pheromones-every-number-of-ticks 3
  ;set food-source-colors [red sky yellow orange lime brown cyan magenta pink gray turquoise violet green blue]
  set food-source-colors [red sky violet lime orange brown yellow magenta blue pink green gray turquoise cyan]
  set nest-source-colors [red violet orange lime pink gray turquoise magenta cyan sky green blue]
end

to update-pheromone-color-rgb
  set food-pheromone-color-rgb extract-rgb food-pheromone-color
  set nest-pheromone-color-rgb extract-rgb nest-pheromone-color
end

to setup-nests
  create-circular-nest 0 0 5
  ;create-circular-nest -20 10 5
end

to setup-food
  create-circular-mound-food-source (0.6 * max-pxcor) 0 5
  create-circular-mound-food-source (-0.6 * max-pxcor) (-0.6 * max-pycor) 5
  create-circular-mound-food-source (-0.8 * max-pxcor) (0.8 * max-pycor) 5
end

to setup-ants
  let number-of-ants 200
  let existing-nest-source-numbers remove-duplicates [source-number] of nests
  let amount-of-ants-to-spawn-at-each-nest number-of-ants / (length existing-nest-source-numbers)
  foreach existing-nest-source-numbers [-nest-source-number -> spawn-ants-at-nest amount-of-ants-to-spawn-at-each-nest -nest-source-number]
  set min-who-number-of-ants-after-setup min [who] of ants
end

to setup-patches
  ask patches [
    set food-pheromone-list []
    set nest-pheromone-list []
    set is-barrier false
    set amount-of-food 0
    ;set is-nest false
;    sprout-patch-pheromone-gfx 1 [
;      set shape "square full"
;      ;set shape "polygon full"
;      set color [0 0 0 0]
;      ;set pheromone-gfx self
;      ;hide-turtle
;    ]
  ]
end

;to start-profiler
;  profiler:start
;end

;to stop-profiler
;  profiler:stop
;  print profiler:report
;  profiler:reset
;end

to update-all-nest-information
  foreach nest-source-numbers-used-so-far [-nest-source-number -> update-nest-information-gfx-overlay -nest-source-number]
end

;to update-all-food-information
;  foreach food-source-numbers-used-so-far [-food-source-number -> update-food-information-gfx-overlay -food-source-number]
;end

to user-set-brush-to-draw
  set brush-in-draw-mode true
  on-user-set-brush-to-draw
end

to user-set-brush-to-erase
  set brush-in-draw-mode false
  on-user-set-brush-to-erase
end

to on-user-set-brush-to-draw
  set-brush-draw-erase-icon-to-draw
  set-brush-cursor-icon-to-draw
end

to on-user-set-brush-to-erase
  set-brush-draw-erase-icon-to-erase
  set-brush-icon-to-erase
end

to set-brush-cursor-icon-to-draw
  ask -brush-cursor [set shape "brush-cursor-draw6" set size 3]
end

to set-brush-icon-to-erase
  ask -brush-cursor [set shape "brush-cursor-erase" set size 3]
end

to update-brush-cursor-icon
  ifelse is-brush-in-draw-mode [
    set-brush-cursor-icon-to-draw ]
  [
    set-brush-icon-to-erase ]
end

to set-brush-draw-erase-icon-to-draw
  ask brush-draw-erase-mode-icon [set shape "brush-mode-icon-draw2"]
end

to set-brush-draw-erase-icon-to-erase
  ask brush-draw-erase-mode-icon [set shape "brush-mode-icon-erase"]
end

;to prompt-user-to-choose-background-image
;  let user-background-image-file user-file
;  if user-background-image-file != false [
;    set local-background-image-file-path-chosen-by-user user-background-image-file
;    carefully [
;      set-background-image-to-file-chosen-by-user ]
;    [
;      user-message-file-not-valid-as-background-image
;    ]
;  ]
;end

;to user-message-file-not-valid-as-background-image
;      user-message "הקובץ שנבחר לא יכול לשמש כתמונת רקע"
;end

to show-pheromones
  set show-pheromone? true
  recolor-all-patches
;  ask patches [ask pheromone-gfx [show-turtle] ]
end

to hide-pheromones
  set show-pheromone? false
  recolor-all-patches
;  ask patches [ask pheromone-gfx [hide-turtle] ]
end

to set-brush-shape [-brush-shape]
  set brush-shape -brush-shape
end

;to update-food-information-gfx-overlay [-food-source-number]
;  update-food-count-gfx-overlay-for-food-source -food-source-number
;end

to update-nest-information-gfx-overlay [-nest-source-number]
  update-food-count-gfx-overlay-for-nest -nest-source-number
  update-ant-count-gfx-overlay-for-nest -nest-source-number
end

to update-ant-count-gfx-overlay-for-nest [-nest-source-number]
  ask get-nest-information-gfx-overlay -nest-source-number [
    ;ask ant-count-gfx-overlay [set label word "Ants: " amount-of-ants-belonging-to-nest -nest-source-number]
    ask ant-count-gfx-overlay [set label word "נמלים: " amount-of-ants-belonging-to-nest -nest-source-number]
  ]
end

to create-circular-nest-with-ants-and-automatically-determine-nest-source [nest-center-xcor nest-center-ycor nest-radius number-of-ants-to-create]
  create-nest-in-patches-and-automatically-determine-source-number ([patches in-radius nest-radius] of patch nest-center-xcor nest-center-ycor)
  create-ants-at nest-center-xcor nest-center-ycor number-of-ants-to-create ([nest-source-number-at-patch] of patch nest-center-xcor nest-center-ycor)
end

to create-circular-nest-with-ants [nest-center-xcor nest-center-ycor nest-radius number-of-ants-to-create]
  let designated-patches-to-create-new-curcilar-nest [patches in-radius nest-radius] of patch nest-center-xcor nest-center-ycor
  let patches-without-existing-nest-in-designated-area designated-patches-to-create-new-curcilar-nest with [not patch-has-nest]
  if any? patches-without-existing-nest-in-designated-area [
    create-nest-in-patches-with-new-source-number patches-without-existing-nest-in-designated-area
    let source-number-of-newly-created-nest [nest-source-number-at-patch] of one-of patches-without-existing-nest-in-designated-area
    let nest-center-patch center-agent-world-wrap patches-without-existing-nest-in-designated-area
    create-ants-at ([pxcor] of nest-center-patch) ([pycor] of nest-center-patch) number-of-ants-to-create source-number-of-newly-created-nest
  ]
end

to create-ants-at [-xcor -ycor number-of-ants-to-create home-nest]
  let ants-created []
  create-ants number-of-ants-to-create
  [
    set home-nest-source-number home-nest
    set size 2
    ;set leader nobody
    set pheromone-zero-clock random 10
    set xcor -xcor
    set ycor -ycor
    set-shape-of-ant-not-carrying-food
    set-color-of-ant-not-carrying-food
    set ants-created lput self ants-created
  ]
  on-ants-created ants-created
end

to on-ants-created [ants-created]
  let home-nest-source-number-of-ants-created [home-nest-source-number] of one-of ants-created
  update-ant-count-gfx-overlay-for-nest home-nest-source-number-of-ants-created
end

to spawn-ants-at-nest [amount -nest-source-number]
  let center-of-nest nest-center -nest-source-number
  create-ants-at [xcor] of center-of-nest [ycor] of center-of-nest amount -nest-source-number
end

to switch-current-nest-displaying-pheromone
  ifelse any-nest-exists? [
    let existing-nests-with-source-number-higher-than-current-nest-displaying-pheromone
      filter [-nest-source-number -> -nest-source-number > current-nest-displaying-pheromone] existing-nests-source-number
    ifelse not empty? existing-nests-with-source-number-higher-than-current-nest-displaying-pheromone [
      set current-nest-displaying-pheromone min existing-nests-with-source-number-higher-than-current-nest-displaying-pheromone ]
    [
      set current-nest-displaying-pheromone min existing-nests-source-number
    ]
  ]
  [
    set current-nest-displaying-pheromone (current-nest-displaying-pheromone + 1) mod (length nest-source-numbers-used-so-far)
  ]
end

to display-pheromones-of-another-nest
  switch-current-nest-displaying-pheromone
  recolor-all-patches
end

to-report any-nest-exists?
  report not empty? existing-nests-source-number
end

to-report existing-nests-source-number
  report sort filter [-nest-source-number -> any? (nests with [source-number = -nest-source-number])] nest-source-numbers-used-so-far
end

;to create-food-in-radius-at [-xcor -ycor radius -amount-of-food]
;  let -food-source-number new-food-source-number
;  create-food -amount-of-food [setxy (-xcor + (((random-normal 0 0.5) / 3) * radius)) (-ycor + ( ((random-normal 0 0.5) / 3) * radius))
;    set source-number -food-source-number set shape "seed-outline" set color food-source-number-color -food-source-number set size 2 ]
;end

to recolor-all-patches
  ask patches [recolor-patch]
end

to remove-ants-in-patches [-patches]
  ask -patches [remove-ants-in-patch]
end

; patch prodedure
to remove-ants-in-patch
  on-ants-about-to-be-removed ants-here
  ask ants-here [die]
  on-ants-removed
end

to on-ants-removed
  foreach nest-source-numbers-used-so-far [-nest-source-number -> update-ant-count-gfx-overlay-for-nest -nest-source-number]
end

to on-ants-about-to-be-removed [ants-to-be-removed]
  let nests-of-ants-that-are-about-to-be-removed remove-duplicates [home-nest-source-number] of ants-to-be-removed
end

to create-circular-mound-food-source [-xcor -ycor radius]
  let center-patch-of-food patch -xcor -ycor
  let -food-source-number new-food-source-number
  let food-patches pacthes-in-radius -xcor -ycor radius
  ;i experimented with some numbers ot make food mound look nice, but the mound calculation should be put in a procedure of its own
  ask food-patches [create-food-in-patch int ((exponential-distribution 0.3 (distance center-patch-of-food)) * 20 + 1) * 2 -food-source-number]
end

to create-circular-food-source [-xcor -ycor radius]
  let circular-food-source-patches pacthes-in-radius -xcor -ycor radius
  create-food-in-patches-and-automatically-determine-food-source circular-food-source-patches
end

to create-circular-nest [-xcor -ycor radius]
  create-nest-in-patches-and-automatically-determine-source-number pacthes-in-radius -xcor -ycor radius
end

to create-nest-in-patches [-patches -nest-source-number]
  foreach [self] of -patches [-patch -> create-nest-in-patch -patch -nest-source-number]
end

; patch prodcedure
to create-nest-in-patch [-patch -nest-source-number]
  if [can-create-nest-in-patch] of -patch [
    let nest-created nobody
    ask -patch [sprout-nests 1 [
      hide-turtle
      set shape "empty"
      ;set shape "tile stones"
      set source-number -nest-source-number
      set-nest-color-based-on-source-number
      set nest-created self]]
    register-use-of-nest-source-number -nest-source-number
    on-nest-created nest-created
  ]
end

; patch prodcedure
to on-nest-created [nest-created]
  update-center-of-nest [source-number] of nest-created
  update-nest-information-gfx-overlay [source-number] of nest-created
end

to update-center-of-food-source [-food-source-number]
  ifelse food-source-has-food -food-source-number [
    ; done for efficiency purposes, look first at patch that is the average of coordinates of all patches with food source,
    ; most of the time that patch will be occupied by the food source
    let -patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source
        patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source -food-source-number
    ifelse [patch-has-food] of -patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source and
           [food-source-number] of -patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source = -food-source-number [
      set center-of-food-sources replace-item -food-source-number center-of-food-sources -patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source ]
    [
      set center-of-food-sources replace-item -food-source-number center-of-food-sources center-food-source-patch -food-source-number]
    ]
  [
    set center-of-food-sources replace-item -food-source-number center-of-food-sources nobody
  ]
end

to-report patch-located-at-average-of-xy-coordinates-of-patches-occupied-by-food-source [-food-source-number]
  let -average-xy-coordinates-of-patches-occupied-by-food-source average-xy-coordinates-of-patches-occupied-by-food-source -food-source-number
  let average-xcor (item 1 -average-xy-coordinates-of-patches-occupied-by-food-source) / (item 0 -average-xy-coordinates-of-patches-occupied-by-food-source)
  let average-ycor (item 2 -average-xy-coordinates-of-patches-occupied-by-food-source) / (item 0 -average-xy-coordinates-of-patches-occupied-by-food-source)
  report patch average-xcor average-ycor
end

to update-center-of-nest [-nest-source-number]
  let -nest-agents nest-agents -nest-source-number
  ifelse any? -nest-agents [
    set center-of-nests replace-item -nest-source-number center-of-nests center-agent -nest-agents]
  [
    set center-of-nests replace-item -nest-source-number center-of-nests nobody
  ]
  on-center-of-nest-updated -nest-source-number
end

to on-center-of-nest-updated [-nest-source-number]
  let -nest-center nest-center -nest-source-number
  ifelse -nest-center != nobody [
    update-position-of-nest-information -nest-source-number [xcor] of -nest-center [ycor] of -nest-center ]
  [
    hide-nest-information -nest-source-number
  ]
end

to update-position-of-nest-information [-nest-source-number -xcor -ycor]
  ask get-nest-information-gfx-overlay -nest-source-number [
    carefully [
      ask nest-source-number-gfx-overlay [show-turtle setxy (-xcor + 2) (-ycor + 1)]
      ask food-count-gfx-overlay [show-turtle setxy (-xcor + 2) -ycor]
      ask ant-count-gfx-overlay [show-turtle setxy (-xcor + 2) (-ycor - 1)] ]
    []
  ]
end

to hide-nest-information [-nest-source-number]
  ask get-nest-information-gfx-overlay -nest-source-number [
    ask nest-source-number-gfx-overlay [hide-turtle]
    ask food-count-gfx-overlay [hide-turtle]
    ask ant-count-gfx-overlay [hide-turtle]
  ]
end

to-report nest-agents [-source-number]
  report nests with [source-number = -source-number]
end

; turtle variable
to set-nest-color-based-on-source-number
  set color nest-source-number-color source-number
end

;food-source-number-color
to-report nest-source-number-color [-source-number]
  report item (-source-number mod (length nest-source-colors - 1) ) nest-source-colors
end


to register-use-of-nest-source-number [-source-number]
  if not member? -source-number nest-source-numbers-used-so-far [
    set nest-source-numbers-used-so-far lput -source-number nest-source-numbers-used-so-far
    on-new-nest-source-number-used -source-number
  ]
end

to on-new-nest-source-number-used [-source-number]
  set amount-of-food-in-nests lput 0 amount-of-food-in-nests
  set center-of-nests lput nobody center-of-nests
  set nests-information-gfx-overlay lput (create-initialized-nest-information-gfx-overlay -source-number) nests-information-gfx-overlay
  ask patches [
    set food-pheromone-list lput 0 food-pheromone-list
    set nest-pheromone-list lput 0 nest-pheromone-list
  ]
  plot-food-in-nest
end

to-report create-initialized-nest-information-gfx-overlay [-nest-source-number]
  let new-nest-information-gfx-overlay nobody
  let new-gfx-overlays n-values 3 [create-initialized-gfx-overlay]
  create-nest-information-gfx-overlay 1 [
    set new-nest-information-gfx-overlay self
    hide-turtle
    set shape "empty"
    set nest-source-number-gfx-overlay item 0 new-gfx-overlays
    ;ask nest-source-number-gfx-overlay [set label word "Nest: " -nest-source-number]
    ;ask nest-source-number-gfx-overlay [set label word "מספר קן: " (-nest-source-number + 1)]
    ask nest-source-number-gfx-overlay [set label word "קן מס': " (-nest-source-number + 1)]
    ;ask nest-source-number-gfx-overlay [set label word "קן: " (-nest-source-number + 1)]
    set food-count-gfx-overlay item 1 new-gfx-overlays
    set ant-count-gfx-overlay item 2 new-gfx-overlays
  ]
  report new-nest-information-gfx-overlay
end

to-report create-initialized-gfx-overlay
  let gfx-overlay-created nobody
  create-gfx-overlay 1 [set gfx-overlay-created self hide-turtle set shape "empty"]
  report gfx-overlay-created
end

; patch procedure
to-report sprout-initialized-gfx-overlay
  let gfx-overlay-created nobody
  sprout-gfx-overlay 1 [set gfx-overlay-created self hide-turtle set shape "empty"]
  report gfx-overlay-created
end

to on-add-nest-brush-activated
  create-nest-in-patches-and-automatically-determine-source-number newly-drawn-on-patches-brush-is-drawing-on
end

; patch procedure
to-report can-create-nest-in-patch
  report not (patch-has-nest or patch-has-barrier)
end

to-report exponential-distribution [lambda x]
  report lambda * e ^ (-1 * lambda * x)
end

to-report amount-of-ants-belonging-to-nest [-nest-source-number]
  report count ants with [home-nest-source-number = -nest-source-number]
end

to-report pacthes-in-radius [center-xcor center-ycor radius]
  report [patches in-radius radius] of patch center-xcor center-ycor
end

;turtle procedure
to-report is-carrying-food
  report amount-of-food-carried > 0
end

to remove-nest-from-patches [-patches]
   ask -patches [remove-nest-from-patch]
end

; patch procedure
to remove-nest-from-patch
  if any? nests-here [
    let source-number-of-nest-removed [source-number] of one-of nests-here
    ask nests-here [die]
    on-nest-removed-from-patch source-number-of-nest-removed ]
end

; patch procedure
to on-nest-removed-from-patch [source-number-of-nest-removed]
  update-center-of-nest source-number-of-nest-removed
end

to-report is-brush-in-draw-mode
  report (brush-in-draw-mode = true)
end

to-report is-brush-in-erase-mode
  report not is-brush-in-draw-mode
end

to on-add-food-brush-activated
  create-food-in-patches-and-automatically-determine-food-source newly-drawn-on-patches-brush-is-drawing-on
end

to remove-food-from-patches [-patches]
  ask -patches [remove-food-from-patch]
end

;patch-procedure
to remove-food-from-patch
  reduce-food-in-patch amount-of-food
  ;ask food-here [die]
end

to-report one-of-patches-is-neighbor-of-existing-nest [-patches]
  report any? -patches with [patch-is-neighbor-of-existing-nest]
end

; patch procedure
to-report patch-is-neighbor-of-existing-nest
  report any? neighbor-patches-with-nests
end

; patch procedure
to-report neighbor-patches-with-nests
  report neighbors with [patch-has-nest]
end

to create-nest-with-same-source-number-as-one-of-neighbors [-patches]
  let -source-number source-number-of-one-of-nest-neighbors-of-patches -patches
  create-nest-in-patches -patches -source-number
end

to-report source-number-of-one-of-nest-neighbors-of-patches [-patches]
  report [source-number-of-one-of-nest-neighbors] of one-of -patches with [patch-is-neighbor-of-existing-nest]
end

; patch procedure
to-report source-number-of-one-of-nest-neighbors
  report [source-number] of one-of (turtle-set [nests-here] of neighbors)
end

to create-nest-in-patches-and-automatically-determine-source-number [-patches]
  ifelse one-of-patches-is-neighbor-of-existing-nest -patches [
    create-nest-with-same-source-number-as-one-of-neighbors -patches ]
  [ create-nest-in-patches-with-new-source-number -patches]
end

to create-nest-in-patches-with-new-source-number [-patches]
  let -source-number new-nest-source-number
  create-nest-in-patches -patches -source-number
end

to-report new-nest-source-number
  ifelse empty? nest-source-numbers-used-so-far [
    report 0 ]
  [ report max nest-source-numbers-used-so-far + 1]
end

to create-food-in-patches-and-automatically-determine-food-source [-patches]
  ifelse one-of-patches-is-neighbor-of-existing-food-source -patches [
    create-food-with-same-food-source-as-one-of-neighbors -patches ]
  [ create-food-in-patches-as-new-food-source -patches]
end

to create-food-with-same-food-source-as-one-of-neighbors [-patches]
  let -food-source-number food-source-of-one-of-neighbors -patches
  ask -patches [create-food-in-patch how-much-food-to-add-in-patch -food-source-number]
end

to-report food-source-of-one-of-neighbors [-patches]
  report [food-source-number-of-any-neighbor] of one-of -patches with [patch-is-neighbor-of-existing-food-source]
end


to create-food-in-patches-as-new-food-source [-patches]
  let -food-source-number new-food-source-number
  ask -patches [create-food-in-patch how-much-food-to-add-in-patch -food-source-number]
end

to-report one-of-patches-is-neighbor-of-existing-food-source [-patches]
  report any? -patches with [patch-is-neighbor-of-existing-food-source]
end

;patch procedure
to-report amount-of-food-on-patch
  report amount-of-food
  ;report count food-here
end

to-report food-source-number-color [-food-source-number]
  report item (-food-source-number mod (length food-source-colors - 1) ) food-source-colors
end

to-report how-much-food-to-add-in-patch
  report random 3 + 1
end

to-report new-food-source-number
  ifelse empty? food-source-numbers-used-so-far [
    report 0 ]
  [ report max food-source-numbers-used-so-far + 1]
end

; patch procedure
to create-food-in-patch [-amount-of-food -food-source-number]
  if can-add-food-in-patch [
    if not patch-has-food [
      set food-source-number -food-source-number ]
    set amount-of-food amount-of-food + -amount-of-food
    ;sprout-food -amount-of-food [set shape "seed-outline" set source-number -food-source-number set size 1.5
    ;  setxy (pxcor + (random-float 1) - 0.5) (pycor + (random-float 1) - 0.5) set color food-source-number-color -food-source-number]
    register-use-of-food-source-number -food-source-number
    on-food-created -amount-of-food food-source-number
  ]
end

; patch procedure
to on-food-created [-amount-of-food -food-source-number]
  let updated-food-count-of-food-source item -food-source-number food-count-in-each-food-source + -amount-of-food
  set food-count-in-each-food-source replace-item -food-source-number food-count-in-each-food-source updated-food-count-of-food-source
  let patch-had-no-food-before-this-food-was-added ifelse-value amount-of-food = -amount-of-food [true] [false]
  if patch-had-no-food-before-this-food-was-added [
    add-patch-to-patch-set-occupying-food-source
    add-patch-to-average-xy-coordinates-of-patches-occupied-by-food-source
    update-center-of-food-source -food-source-number
    update-position-of-food-information -food-source-number
  ]
  update-food-count-gfx-overlay-for-food-source -food-source-number
end

; patch procedure
to on-food-reduced-from-patch [amount-reduced -food-source-number]
  let updated-food-count-of-food-source (food-count-in-food-source -food-source-number) - amount-reduced
  set food-count-in-each-food-source replace-item -food-source-number food-count-in-each-food-source updated-food-count-of-food-source
  if amount-of-food = 0 [
    remove-patch-from-patch-set-occupying-food-source
    remove-patch-from-average-xy-coordinates-of-patches-occupied-by-food-source
    update-center-of-food-source -food-source-number
    update-position-of-food-information -food-source-number
  ]
  update-food-count-gfx-overlay-for-food-source -food-source-number
end

; patch procedure
to add-patch-to-patch-set-occupying-food-source
  set patches-occupied-by-food-sources replace-item food-source-number patches-occupied-by-food-sources (patch-set item food-source-number patches-occupied-by-food-sources self)
end

; patch procedure
to remove-patch-from-patch-set-occupying-food-source
  set patches-occupied-by-food-sources replace-item food-source-number patches-occupied-by-food-sources other item food-source-number patches-occupied-by-food-sources
end

to update-position-of-food-information [-food-source-number]
  ifelse food-source-has-food -food-source-number [
    ask get-food-source-information-gfx-overlay -food-source-number [
      let -center-food-source-patch item -food-source-number center-of-food-sources
      carefully [
        ask food-source-number-gfx-overlay [show-turtle setxy ([pxcor] of -center-food-source-patch + 2) [pycor] of -center-food-source-patch]
        ask food-count-gfx-overlay [show-turtle setxy ([pxcor] of -center-food-source-patch + 2) ([pycor] of -center-food-source-patch - 1)]
      ] []
    ]
  ]
  [
    hide-food-source-information -food-source-number
  ]
end

to hide-food-source-information [-food-source-number]
  ask get-food-source-information-gfx-overlay -food-source-number [
    ask food-source-number-gfx-overlay [hide-turtle]
    ask food-count-gfx-overlay [hide-turtle]
  ]
end

to-report food-source-has-food [-food-source-number]
  report item -food-source-number food-count-in-each-food-source > 0
end

to on-center-of-nest-updated1 [-nest-source-number]
  let -nest-center nest-center -nest-source-number
  ifelse -nest-center != nobody [
    update-position-of-nest-information -nest-source-number [xcor] of -nest-center [ycor] of -nest-center ]
  [
    hide-nest-information -nest-source-number
  ]
end

to update-position-of-nest-information1 [-nest-source-number -xcor -ycor]
  ask get-nest-information-gfx-overlay -nest-source-number [
    carefully [
      ask nest-source-number-gfx-overlay [show-turtle setxy (-xcor + 2) (-ycor + 1)]
      ask food-count-gfx-overlay [show-turtle setxy (-xcor + 2) -ycor]
      ask ant-count-gfx-overlay [show-turtle setxy (-xcor + 2) (-ycor - 1)] ]
    []
  ]
end

; patch procedure
to add-patch-to-average-xy-coordinates-of-patches-occupied-by-food-source
  let -average-xy-coordinates-of-patches-occupied-by-food-source average-xy-coordinates-of-patches-occupied-by-food-source food-source-number
  let amount-of-patches-with-food-source item 0 -average-xy-coordinates-of-patches-occupied-by-food-source + 1
  let average-xcor-of-patches-occupied-by-food-source item 1 -average-xy-coordinates-of-patches-occupied-by-food-source + pxcor
  let average-ycor-of-patches-occupied-by-food-source item 2 -average-xy-coordinates-of-patches-occupied-by-food-source + pycor
  set average-xy-coordinates-of-patches-occupied-by-food-sources replace-item food-source-number average-xy-coordinates-of-patches-occupied-by-food-sources
        (list amount-of-patches-with-food-source average-xcor-of-patches-occupied-by-food-source average-ycor-of-patches-occupied-by-food-source)
end

; patch procedure
to remove-patch-from-average-xy-coordinates-of-patches-occupied-by-food-source
  let -average-xy-coordinates-of-patches-occupied-by-food-source average-xy-coordinates-of-patches-occupied-by-food-source food-source-number
  let amount-of-patches-with-food-source item 0 -average-xy-coordinates-of-patches-occupied-by-food-source - 1
  let average-xcor-of-patches-occupied-by-food-source item 1 -average-xy-coordinates-of-patches-occupied-by-food-source - pxcor
  let average-ycor-of-patches-occupied-by-food-source item 2 -average-xy-coordinates-of-patches-occupied-by-food-source - pycor
  set average-xy-coordinates-of-patches-occupied-by-food-sources replace-item food-source-number average-xy-coordinates-of-patches-occupied-by-food-sources
        (list amount-of-patches-with-food-source average-xcor-of-patches-occupied-by-food-source average-ycor-of-patches-occupied-by-food-source)
end

to-report average-xy-coordinates-of-patches-occupied-by-food-source [-food-source-number]
  report item -food-source-number average-xy-coordinates-of-patches-occupied-by-food-sources
end

to create-food-in-patches [-patches -food-source-number]
  ask -patches [create-food-in-patch how-much-food-to-add-in-patch -food-source-number]
end

to register-use-of-food-source-number [-food-source-number]
  if not member? -food-source-number food-source-numbers-used-so-far [
    set food-source-numbers-used-so-far lput -food-source-number food-source-numbers-used-so-far
    on-food-source-created -food-source-number
  ]
end

to on-food-source-created [-food-source-number]
  set food-count-in-each-food-source lput 0 food-count-in-each-food-source
  set patches-occupied-by-food-sources lput no-patches patches-occupied-by-food-sources
  set center-of-food-sources lput nobody center-of-food-sources
  set average-xy-coordinates-of-patches-occupied-by-food-sources lput [0 0 0] average-xy-coordinates-of-patches-occupied-by-food-sources
  set food-sources-information-gfx-overlay lput (create-initialized-food-information-gfx-overlay -food-source-number) food-sources-information-gfx-overlay
  plot-food-sources
end

to-report create-initialized-food-information-gfx-overlay [-food-source-number]
  let new-food-information-gfx-overlay nobody
  let new-gfx-overlays n-values 3 [sprout-initialized-gfx-overlay]
  sprout-food-information-gfx-overlay 1 [
    set new-food-information-gfx-overlay self
    hide-turtle
    set shape "empty"
    set food-source-number-gfx-overlay item 0 new-gfx-overlays
    ask food-source-number-gfx-overlay [set label word "מאגר: " (-food-source-number + 1)]
    set food-count-gfx-overlay item 1 new-gfx-overlays
    ;ask food-count-gfx-overlay [if shade-of? food-source-number-color -food-source-number yellow [set label-color 64]]
    ;ask food-count-gfx-overlay [set shape "square" set color add-transparency black 0.5 set size 3]
  ]
  report new-food-information-gfx-overlay
end

; patch procedure
to-report food-source-number-of-any-neighbor
  report [food-source-number] of one-of (neighbors with [patch-has-food])
  ;report [source-number] of one-of (turtle-set [food-here] of neighbors)
end

; patch procedure
to-report neighbor-patches-with-food
  report neighbors with [patch-has-food]
end

; patch prodecure
to-report patch-is-neighbor-of-existing-food-source
  report any? neighbor-patches-with-food
end

; patch procedure
to-report can-add-food-in-patch
  report not (patch-has-barrier)
end

to-report patches-affected-by-a-square-shaped-brush-at-patch [-patch]
  report (patch-set n-values (brush-size ^ 2) [i -> patch (([pxcor] of -patch - (brush-size / 2) + 0.5) + i mod brush-size) (([pycor] of -patch - (brush-size / 2) + 0.5) + int(i / brush-size))])
end

to-report patches-affected-by-a-circle-shaped-brush-at-patch [-patch]
  report [patches in-radius (brush-size / 2)] of -patch
end

to-report patches-affected-by-brush-shape-used-at-patch [-patch]
  ifelse brush-shape = "circle" [
    report patches-affected-by-a-circle-shaped-brush-at-patch -patch]
  [ if brush-shape = "square"
    [report patches-affected-by-a-square-shaped-brush-at-patch -patch ]
  ]
end

to-report ants-under-brush
  ifelse brush-shape = "circle" [
    report [ants in-radius brush-size] of patch-under-brush]
  [ if brush-shape = "square" [
    report turtle-set [ants-here] of patches-under-brush ]
  ]
end

to-report patches-under-brush
  report patches-affected-by-brush-shape-used-at-patch patch-under-brush
end

to-report patches-brush-is-drawing-on
    report patch-set [patches-affected-by-brush-shape-used-at-patch self] of patches-brush-moved-over-while-being-held-down
end

to-report patches-brush-moved-over-while-being-held-down
    report patches-line-intersects coordinates-of-brush-when-last-held-down mouse-coordinates
end

to-report coordinates-of-brush-when-last-held-down
  report mousexy-when-brush-was-last-activated
  ;ifelse mouse-down?-when-brush-was-last-activated [report mousexy-when-brush-was-last-activated] [report mouse-coordinates]
end

to-report newly-drawn-on-patches-brush-is-drawing-on
  report patch-set patches-brush-is-drawing-on with [not member? self get-patches-drawn-on-since-brush-was-held-down]
end

to-report patch-under-brush
  report patch-at-point mouse-coordinates
end

to-report mouse-coordinates
  report current-mousexy
end

to set-brush-type [-brush-type]
  set brush-type -brush-type
  on-brush-type-set
end

to on-brush-type-set
  update-brush-type-icon
end

to-report brush-type-already-chosen [-brush-type]
  report brush-type = -brush-type
end

to toggle-add-erase
  set brush-in-draw-mode ifelse-value brush-in-draw-mode = true [false] [true]
end

to display-brush-border-outline
  ifelse current-mouse-inside? [
    show-brush-border-outline
    set-brush-border-outline-coordinates
    set-brush-border-outline-shape
    set-brush-border-outline-color
    set-brush-border-outline-size
    set-brush-border-outline-label ]
  [
    hide-brush-border-outline ]
end

to display-brush-cursor
  ifelse current-mouse-inside? [
    show-brush-cursor
    set-brush-cursor-coordinates ]
  [
    hide-brush-cursor ]
end

to hide-brush-cursor
  ask -brush-cursor [hide-turtle]
end

to show-brush-cursor
  ask -brush-cursor [show-turtle]
end

to set-brush-cursor-coordinates
  carefully [ ask -brush-cursor [set xcor (item 0 current-mousexy + 1.5)] ] []
  carefully [ ask -brush-cursor [set ycor (item 1 current-mousexy + 1.5)] ] []
  ;carefully [ ask -brush-cursor [set xcor ([pxcor] of patch-under-brush + 1.5)] ] []
  ;carefully [ ask -brush-cursor [set ycor ([pycor] of patch-under-brush + 1.5)] ] []
end

to display-brush-gfx
  display-brush-border-outline
  display-brush-cursor
  diplay-brush-xy-as-label-on-brush-mode-icon
  make-sure-brush-gets-updated-in-display-atleast-every 0.04
end

to diplay-brush-xy-as-label-on-brush-mode-icon
  ifelse current-mouse-inside? [
    ask brush-draw-erase-mode-icon [set label (word int item 0 current-mousexy ", " int item 1 current-mousexy) ] ]
  [
    ask brush-draw-erase-mode-icon [set label ""]
  ]
end

to set-brush-border-outline-label
  ;ask patch 0 min-pycor [set plabel brush-type]
end

to set-brush-border-outline-coordinates
  let -patch-under-brush patch-under-brush
  ifelse brush-shape = "square" [ ;offset brush for even sizes since patch under brush can not be center
    carefully [
      ask -brush-border-outline [setxy ([pxcor] of -patch-under-brush + 0.5 * ((brush-size + 1) mod 2)) ([pycor] of -patch-under-brush + 0.5 * ((brush-size + 1) mod 2))]
    ] []
  ]
  [
    ask -brush-border-outline [setxy [pxcor] of -patch-under-brush [pycor] of -patch-under-brush]
  ]
end

to hide-brush-border-outline
  ask -brush-border-outline [hide-turtle]
end

to show-brush-border-outline
  ask -brush-border-outline [show-turtle]
end

to set-brush-border-outline-shape
  ifelse brush-shape = "square" [
    ask -brush-border-outline [set shape "square outline thick"] ]
  [
    ifelse  brush-shape = "circle" [
      ask -brush-border-outline [set shape "circle outline"] ]
    [] ]
end

to set-brush-border-outline-color
  ifelse is-brush-in-draw-mode [
    ask -brush-border-outline [set color cyan] ]
  [
    ask -brush-border-outline [set color red] ]
end

to set-brush-border-outline-size
  ask -brush-border-outline [set size brush-size]
end

to activate-brush
  set-brush-state
  display-brush-gfx
  draw-with-brush
  keep-track-of-current-brush-state
end

to set-brush-state
  set current-mousexy (list mouse-xcor mouse-ycor)
  set current-mouse-down? mouse-down?
  set current-mouse-inside? mouse-inside?
end

to keep-track-of-current-brush-state
  update-which-patches-have-been-affected-by-brush-since-it-was-held-down
  set mouse-down?-when-brush-was-last-activated current-mouse-down?
  set mousexy-when-brush-was-last-activated current-mousexy
end

to-report brush-is-held-down
  report current-mouse-down?
end

to update-which-patches-have-been-affected-by-brush-since-it-was-held-down
  ifelse brush-is-held-down [
    set patches-drawn-on-since-brush-was-held-down (patch-set patches-drawn-on-since-brush-was-held-down
      patches-brush-is-drawing-on) ]
  [
    set patches-drawn-on-since-brush-was-held-down no-patches ]
end

to draw-with-brush
  ifelse brush-is-held-down [
    on-brush-is-held-down
    if is-brush-drawing-on-patches-not-drawn-on-since-brush-was-held-down [
      on-brush-drawing-only-once-per-patch]]
  [
    if brush-has-been-clicked [
      on-brush-has-been-clicked]
  ]
end

to on-brush-is-held-down
  ifelse brush-type =  "ant" [
    on-brush-used-with-ant ]
  [
    ifelse brush-type = "mark" [
      on-brush-used-with-mark ]
    [
      ifelse brush-type = "food-pheromone" [
        on-brush-held-down-with-food-pheromone ]
      [
        if brush-type = "nest-pheromone" [
          on-brush-held-down-with-nest-pheromone ]
      ]
    ]
  ]
end

to on-brush-drawing-only-once-per-patch
  ifelse brush-type =  "nest" [
    use-brush-with-nest ]
  [
    ifelse brush-type =  "food" [
          use-brush-with-food ]
    [
      ifelse brush-type =  "barrier" [
            use-brush-with-barrier ]
      [
        ifelse brush-type = "trail" [
          use-brush-with-trail ]
        [
        ;  ifelse brush-type = "food-pheromone" [
        ;    use-brush-with-food-pheromone ]
        ;  ]
        ;  [
        ;    if brush-type = "nest-pheromone" [
        ;      use-brush-with-nest-pheromone ]
        ;    ]
        ;  ]
        ]
      ]
    ]
  ]
end

to on-brush-has-been-clicked
  if (brush-type =  "ant") [
    use-brush-click-with-ant ]
end

to-report is-brush-drawing-on-patches-not-drawn-on-since-brush-was-held-down
  report any? newly-drawn-on-patches-brush-is-drawing-on
end

to-report get-patches-drawn-on-since-brush-was-held-down
  report patches-drawn-on-since-brush-was-held-down
end

to on-brush-held-down-with-nest-pheromone
  ifelse is-brush-in-draw-mode [on-nest-pheromone-draw-brush-activated ] [on-nest-pheromone-erase-brush-activated ]
  recolor-patches patches-brush-is-drawing-on
end

to on-brush-held-down-with-food-pheromone
  ifelse is-brush-in-draw-mode [on-food-pheromone-draw-brush-activated ] [on-food-pheromone-erase-brush-activated ]
  recolor-patches patches-brush-is-drawing-on
end

;to use-brush-with-nest-pheromone
;  if is-brush-in-draw-mode [
;    on-nest-pheromone-draw-brush-activated ]
; recolor-patches patches-brush-is-drawing-on
;end

;to use-brush-with-food-pheromone
;  if is-brush-in-draw-mode [
;    on-food-pheromone-draw-brush-activated ]
;  recolor-patches patches-brush-is-drawing-on
;end

to use-brush-with-trail
  ifelse is-brush-in-draw-mode [on-pen-down-brush-activated] [on-pen-erase-brush-activated]
end

to on-pen-down-brush-activated
  ask ants-under-brush [pen-down]
end

to on-pen-erase-brush-activated
  ask ants-under-brush [pen-up]
end

to-report ant-is-marked [-ant]
  report any? ant-markers with [ant-being-marked = -ant]
end

; turtle procedure
to mark-ant [-ant]
  if not ant-is-marked -ant [
    create-ant-markers 1 [set ant-being-marked -ant setxy [xcor] of -ant [ycor] of -ant set shape "circle outline" set color yellow set size 2] ]
end

to on-nest-pheromone-draw-brush-activated
  let increased-pheromone-value-depending-on-how-long-brush-pressed-down ((count patches-drawn-on-since-brush-was-held-down) / (world-width * world-height))
  ask patches-brush-is-drawing-on [
    let new-nest-pheromone-value max-pheromone + increased-pheromone-value-depending-on-how-long-brush-pressed-down +
      (((distancexy item 0 mousexy-when-brush-was-last-activated item 1 mousexy-when-brush-was-last-activated) / (world-width + world-height)) / ((world-width * world-height) ^ 2))
    set nest-pheromone-list n-values (length nest-pheromone-list) [new-nest-pheromone-value]
  ]
end

to on-nest-pheromone-erase-brush-activated
  ask patches-brush-is-drawing-on [remove-nest-pheromone-from-patch]
end

to on-food-pheromone-draw-brush-activated
  ;ask newly-drawn-on-patches-brush-is-drawing-on [
  let increased-pheromone-value-depending-on-how-long-brush-pressed-down ((count patches-drawn-on-since-brush-was-held-down) / (world-width * world-height))
  ask patches-brush-is-drawing-on [
    let new-food-pheromone-value max-pheromone + increased-pheromone-value-depending-on-how-long-brush-pressed-down +
      (((distancexy item 0 mousexy-when-brush-was-last-activated item 1 mousexy-when-brush-was-last-activated) / (world-width + world-height)) / ((world-width * world-height) ^ 2))
    set food-pheromone-list n-values (length food-pheromone-list) [new-food-pheromone-value]
  ]
end

to on-food-pheromone-erase-brush-activated
  ask patches-brush-is-drawing-on [remove-food-pheromone-from-patch]
end

to on-add-mark-brush-activated
  foreach [self] of ants-under-brush [-ant -> mark-ant -ant]
end

to on-erase-mark-brush-activated
  ask turtle-set [ant-markers-here] of patches-brush-is-drawing-on [die]
end

to use-brush-click-with-ant
 if is-brush-in-draw-mode [on-add-ant-brush-activated]
end

to on-brush-used-with-mark
  ifelse is-brush-in-draw-mode [on-add-mark-brush-activated] [on-erase-mark-brush-activated]
end

to on-brush-used-with-ant
  if is-brush-in-erase-mode [on-erase-ant-brush-activated]
end

to use-brush-with-barrier
  ifelse is-brush-in-draw-mode [on-add-barrier-brush-activated] [on-erase-barrier-brush-activated]
  recolor-patches newly-drawn-on-patches-brush-is-drawing-on
end

to use-brush-with-food
  ifelse is-brush-in-draw-mode [on-add-food-brush-activated] [on-erase-food-brush-activated]
  recolor-patches newly-drawn-on-patches-brush-is-drawing-on
  plot-food-sources
end

to use-brush-with-nest
  ifelse is-brush-in-draw-mode [on-add-nest-brush-activated] [on-erase-nest-brush-activated]
  recolor-patches newly-drawn-on-patches-brush-is-drawing-on
end

to-report brush-has-been-clicked
  report (not brush-is-held-down) and (brush-was-held-down-last-time-brush-was-activated)
end

to-report brush-was-held-down-last-time-brush-was-activated
  report mouse-down?-when-brush-was-last-activated
end

to make-sure-brush-gets-updated-in-display-atleast-every [seconds]
  update-display-every-given-time-interval-if-ticks-have-not-advanced-since-brush-was-last-activated seconds
  set tick-count-when-brush-was-last-activated ticks
end

to update-display-every-given-time-interval-if-ticks-have-not-advanced-since-brush-was-last-activated [seconds]
  every seconds [
    update-display-if-ticks-have-not-advanced-since-brush-was-last-activated
  ]
end

to update-display-if-ticks-have-not-advanced-since-brush-was-last-activated
  if not ticks-have-advanced-since-last-time-brush-was-activated [
    display ]
end

to-report ticks-have-advanced-since-last-time-brush-was-activated
  let amount-of-ticks-advanced-since-last-time-brush-was-activated ticks - tick-count-when-brush-was-last-activated
  report amount-of-ticks-advanced-since-last-time-brush-was-activated > 0
end

to create-barrier-in-patches [-patches]
  create-barriers-in-patches-in-order-starting-from-center-outwards -patches
end

to create-barriers-in-patches-in-order-starting-from-center-outwards [-patches]
  foreach sort-patches-by-proximity-to-their-most-center-patch -patches [-patch -> ask -patch [create-barrier-in-patch]]
end

to-report sort-patches-by-proximity-to-their-most-center-patch [-patches]
  let -center-patch center-agent-world-wrap -patches
  report sort-by [ [patch1 patch2] -> (distance-between-patches patch1 -center-patch) < (distance-between-patches patch2 -center-patch)] -patches
end

to-report distance-between-patches [patch1 patch2]
  report [distance patch2] of patch1
end

to-report center-agent-world-wrap [-patches]
  report min-one-of -patches [sum-distances-to-patches -patches]
end

to-report center-agent [-patches]
  let mean-xcor mean [xcor] of -patches
  let mean-ycor mean [ycor] of -patches
  report min-one-of -patches [distancexy mean-xcor mean-ycor]
end

to-report center-food-source-patch [-food-source-number]
  let -average-xy-coordinates-of-patches-occupied-by-food-source average-xy-coordinates-of-patches-occupied-by-food-source -food-source-number
  let average-xcor (item 1 -average-xy-coordinates-of-patches-occupied-by-food-source) / (item 0 -average-xy-coordinates-of-patches-occupied-by-food-source)
  let average-ycor (item 2 -average-xy-coordinates-of-patches-occupied-by-food-source) / (item 0 -average-xy-coordinates-of-patches-occupied-by-food-source)
  report min-one-of (item -food-source-number patches-occupied-by-food-sources) [distancexy average-xcor average-ycor]
end

;patch-procedure
to-report sum-distances-to-patches [-patches]
  let patch-to-calculate-distance-from self
  report sum [distance-between-patches patch-to-calculate-distance-from self] of -patches
end

; patch procedure
to create-barrier-in-patch
  if can-attempt-to-create-barrier-in-patch [
    try-to-push-aside-ants-from-patch
    if can-create-barrier-in-patch [
      set is-barrier true ]
      ;sprout-barriers 1 [set shape "tile brick 3" set color barrier-color] ]
  ]
  on-barrier-created-in-patch
end

; patch procedure
to on-barrier-created-in-patch
  set -patches-with-barriers (patch-set -patches-with-barriers self)
end

; patch procedure
to-report can-attempt-to-create-barrier-in-patch
  report not (
    patch-has-food or
    patch-has-nest or
    patch-has-barrier)
end

; patch procedure
to try-to-push-aside-ants-from-patch
  ask ants-here [try-to-move-to-closest-unblocked-neighbors4-patch]
end

;turtle procedure
to try-to-move-to-closest-unblocked-neighbors4-patch
  let closest-unblocked-neighbor-patch closest-unblocked-neighbors4-patch self
  let unblocked-neighbor-exists closest-unblocked-neighbor-patch != nobody
  if unblocked-neighbor-exists [
    move-to closest-unblocked-neighbor-patch ]
end

to-report closest-unblocked-neighbors4-patch [-ant]
  let patch-ant-is-on [patch-here] of -ant
  report min-one-of unblocked-neighbor4-patches patch-ant-is-on [distance patch-ant-is-on]
end

to-report unblocked-neighbor4-patches [-patch]
  report ([neighbors4] of -patch) with [not patch-has-barrier]
end

to-report can-create-barrier-in-patch
  report not (
    patch-has-food or
    patch-has-nest or
    patch-has-barrier or
    patch-has-ants )
end

to recolor-patches [-patches]
  ask -patches [recolor-patch]
end

to on-add-barrier-brush-activated
  create-barrier-in-patches patches-brush-is-drawing-on
  recolor-patches patches-brush-is-drawing-on
end

to on-add-ant-brush-activated
  create-ants-on-patch-under-brush
end

to create-ants-on-patch-under-brush
  let amount-of-ants-to-create brush-size
  let patch-to-create-ants-at patch-under-brush
  let -xcor [pxcor] of patch-to-create-ants-at
  let -ycor [pycor] of patch-to-create-ants-at
  let home-nest-of-ants ifelse-value [patch-has-nest] of patch-under-brush [[nest-source-number-at-patch] of patch-under-brush] [0]
  create-ants-at -xcor -ycor amount-of-ants-to-create home-nest-of-ants
end

; patch procedure
to-report nest-source-number-at-patch
  report [source-number] of one-of nests-here
end

; patch procedure
to remove-barrier-from-patch
  set is-barrier false
  ;ask barriers-here [die]
  on-barrier-removed-from-patch
end

; patch procedure
to on-barrier-removed-from-patch
  set -patches-with-barriers other -patches-with-barriers
end

to remove-barrier-from-patches [-patches]
  ask -patches [remove-barrier-from-patch]
end

to on-erase-nest-brush-activated
  remove-nest-from-patches patches-brush-is-drawing-on
end

to on-erase-food-brush-activated
  remove-food-from-patches patches-brush-is-drawing-on
end

to on-erase-barrier-brush-activated
  remove-barrier-from-patches patches-brush-is-drawing-on
end

to on-erase-ant-brush-activated
  remove-ants-in-patches patches-brush-is-drawing-on
end

; patch procedure
to recolor-patch
  ifelse patch-has-barrier [
    set pcolor barrier-color ]
  [
    ifelse patch-has-food [
      color-food-patch ]
    [
      ifelse patch-has-nest [
        color-nest-in-patch ]
      [
        color-pheromone-in-patch ]
    ]
  ]
end

; patch procedure
to color-nest-in-patch
  set pcolor nest-color-in-patch - 1
end

; patch procedure
to-report nest-color-in-patch
  report [color] of one-of nests-here
  ;report nest-source-number-color nest-source-number
end

; patch procedure
to color-food-patch
  ;set pcolor red
  set pcolor food-color-in-patch
end

;patch-procedure
to-report food-color-in-patch
  report scale-color (food-source-number-color food-source-number) ifelse-value amount-of-food-on-patch > 10 [10] [amount-of-food-on-patch] -2 17
  ;report scale-color (food-source-number-color food-source-number) amount-of-food-on-patch 0 10
end

;patch procedure
to color-pheromone-in-patch
  ifelse show-pheromone? [
    ifelse display-pheromone-type = "food"  [
      ifelse food-pheromone-of-nest current-nest-displaying-pheromone > 3 [
        set pcolor scale-color food-pheromone-color ((food-pheromone-of-nest current-nest-displaying-pheromone) * (pheromone-transparency / 100)) 0 max-pheromone ]
      [set pcolor black]
    ]
    ;ask pheromone-gfx [set color lput transparency-of-currenrtly-displayed-food-pheromone-in-patch food-pheromone-color-rgb ] ]
    [
      ifelse nest-pheromone-of-nest current-nest-displaying-pheromone > 3 [
        set pcolor scale-color nest-pheromone-color nest-pheromone-of-nest current-nest-displaying-pheromone 0 max-pheromone ]
      [set pcolor black]
      ;ask pheromone-gfx [set color lput transparency-of-currenrtly-displayed-nest-pheromone-in-patch nest-pheromone-color-rgb ]
    ]
  ]
  [
    set pcolor black
  ]
end

;patch procedure
to-report transparency-of-currenrtly-displayed-nest-pheromone-in-patch
  report (((nest-pheromone-of-nest current-nest-displaying-pheromone) / max-pheromone) * 255 * (pheromone-transparency / 100))
end

;patch procedure
to-report transparency-of-currenrtly-displayed-food-pheromone-in-patch
  report (((food-pheromone-of-nest current-nest-displaying-pheromone) / max-pheromone) * 255 * (pheromone-transparency / 100))
end

;patch procedure
to-report food-pheromone-of-nest [-nest-source-number]
  ifelse length nest-source-numbers-used-so-far > 0 [
    report item -nest-source-number food-pheromone-list ]
  [
    report 0
  ]
end

;patch procedure
to-report nest-pheromone-of-nest [-nest-source-number]
  ifelse length nest-source-numbers-used-so-far > 0 [
    report item -nest-source-number nest-pheromone-list ]
  [
    report 0
  ]
end

to-report max-pheromone
  ;report world-width + world-height
  report 100
end

;patch procedure
to-report patch-has-barrier
  report is-barrier
  ;report any? barriers-here
end

;patch procedure
to-report patch-has-food
  report amount-of-food > 0
  ;report any? food-here
end

;patch procedure
to-report patch-has-nest
  report any? nests-here
end

;patch procedure
to-report patch-has-ants
  report count-ants-in-patch > 0
end

;patch procedure
to-report count-ants-in-patch
  report count ants-here
end

;turtle procedure
to move-forward [-distance]
  move-ant-ahead-until-it-stops-before-barrier -distance
end

;turtle procedure
to move-forward1 [-distance]
  let step-size 0.1
  let number-of-times-to-move-full-step-size int -distance / step-size
  let remainder-step-size remainder -distance step-size ;- (number-of-times-to-move-full-step-size * step-size)
  repeat number-of-times-to-move-full-step-size [move-forward-if-barrier-not-blocking step-size]
  move-forward-if-barrier-not-blocking remainder-step-size
end

;turtle procedure
to move-ant-ahead-until-it-stops-before-barrier [-distance]
  let -intersection-points-with-barriers-ahead intersection-points-with-barriers-ahead -distance
  let is-barrier-blocking-ant-from-moving-distance not (empty? -intersection-points-with-barriers-ahead)
  ifelse is-barrier-blocking-ant-from-moving-distance [
    let min-distance-to-barrier closest-distance-from-points-to-self -intersection-points-with-barriers-ahead
    if min-distance-to-barrier > 0.001 [
      forward  min-distance-to-barrier * 0.95 ]]
  [
    forward -distance
  ]
end

; turtle procedure
to-report closest-distance-from-points-to-self [points]
  report min (map [point -> distancexy first point last point] points)
end

to-report point-is-on-barrier [point]
  report any? ((patches-at-point-inclusive point) with [patch-has-barrier])
end

;turtle procedure
to move-forward-if-barrier-not-blocking [-distance]
  if not [patch-has-barrier] of patch-ahead -distance [
    forward -distance ]
end

;turtle procedure
to move-backward [-distance]
  let step-size 0.1
  let number-of-times-to-move-full-step-size -distance / step-size
  let remainder-step-size -distance - (number-of-times-to-move-full-step-size * step-size)
  repeat number-of-times-to-move-full-step-size [move-backward-if-barrier-not-blocking step-size]
  move-backward-if-barrier-not-blocking remainder-step-size
end

;turtle procedure
to move-backward-if-barrier-not-blocking [-distance]
  if not [patch-has-barrier] of patch-left-and-ahead 180 -distance [
    back -distance ]
end



;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

to go  ;; forever button
  update-pheromone-color-rgb
  let patches-ants-are-on patch-set [patch-here] of ants
  ;advance-ants-1-turn
  #blocks#advance-ants-1-turn
  spread-pheromones-in-world
  recolor-patches patches-ants-are-on
  update-all-plots
  update-ant-markers
  ;time-run-for-number-of-ticks 500
  tick
end

to time-run-for-number-of-ticks [tick-amount]
  ;if ticks = 0 [reset-timer profiler:reset profiler:start]
  if ticks = 0 [reset-timer]
  ;if ticks = tick-amount [print timer profiler:stop print profiler:report]
  if ticks = tick-amount [print timer]
end

to update-ant-markers
  ask ant-markers [update-ant-marker-position-to-ant-it-is-marking]
end

; turtle procedure
to update-ant-marker-position-to-ant-it-is-marking
  ifelse ant-being-marked != nobody [
    setxy [xcor] of ant-being-marked [ycor] of ant-being-marked ]
  [
    die
  ]
end

to update-all-plots
  plot-food-sources
  plot-food-in-nest
end

to plot-food-in-nest
  set-current-plot "כמות אוכל בקנים"
  foreach nest-source-numbers-used-so-far [nest-source -> update-nest-source-in-plot nest-source]
end

to update-nest-source-in-plot [nest-source]
  set-nest-source-plot-pen nest-source
  plotxy ticks item nest-source amount-of-food-in-nests
end

to set-nest-source-plot-pen [nest-source]
  let nest-source-pen (word "קן " (nest-source + 1))
  ifelse plot-pen-exists? nest-source-pen [
    set-current-plot-pen nest-source-pen ]
  [
    create-temporary-plot-pen nest-source-pen
    set-plot-pen-color nest-source-number-color nest-source
  ]
end

to plot-food-sources
  set-current-plot "כמות אוכל במאגרים"
  foreach food-source-numbers-used-so-far [food-source -> update-food-source-in-plot food-source]
end

to update-food-source-in-plot [food-source]
  set-food-source-plot-pen food-source
  plotxy ticks food-count food-source ;count food with [source-number = food-source]
end

to-report food-count [-food-source-number]
  report item -food-source-number food-count-in-each-food-source
end

to set-food-source-plot-pen [food-source]
  let food-source-pen (word "מאגר " (food-source + 1))
  ;let food-source-pen (word (food-source + 1))
  ifelse plot-pen-exists? food-source-pen [
    set-current-plot-pen food-source-pen ]
  [
    create-temporary-plot-pen food-source-pen
    set-plot-pen-color food-source-number-color food-source
  ]
end

to advance-ants-1-turn
  ask ants [
    ;if (who >= min-who-number-of-ants-after-setup + ticks) [ stop ]
    ;if (who >= ticks) and (who <= number-of-ants) [ stop ] ; delay inital departure of ants, need to find more elegant solution
    ifelse (is-carrying-food) [
      return-to-nest ]
    [
      look-for-food  ]
    move-ant
   ]
end

to spread-pheromones-in-world
;  if ticks mod spread-pheromones-every-number-of-ticks = 0 [
    diffuse-and-evaporate-pheromones
    remove-pheromones-from-patches-with-barriers
;  ]
end

to diffuse-and-evaporate-pheromones
  let diffusion-rate-normalized (pheromone-diffusion-rate / 100)
  let evaporation-rate-normalized (100 - pheromone-evaporation-rate) / 100
  let i 0
  while [i < (length nest-source-numbers-used-so-far)] [
    ask patches [
        set tmp-food-pheromone-value item i food-pheromone-list
        set tmp-nest-pheromone-value item i nest-pheromone-list
    ]

      diffuse tmp-food-pheromone-value diffusion-rate-normalized
      diffuse tmp-nest-pheromone-value diffusion-rate-normalized
;    repeat spread-pheromones-every-number-of-ticks [
;      diffuse tmp-food-pheromone-value diffusion-rate-normalized
;      diffuse tmp-nest-pheromone-value diffusion-rate-normalized
;      remove-pheromones-from-patches-with-barriers
;    ]

    ;ifelse (i = length nest-source-numbers-used-so-far - 1) and (ticks mod (spread-pheromones-every-number-of-ticks * 2) = 0) [
    ifelse (i = length nest-source-numbers-used-so-far - 1) and (ticks mod 6 = 0) [
      ask patches [
        ;set food-pheromone-list replace-item i food-pheromone-list (tmp-food-pheromone-value * (evaporation-rate-normalized ^ spread-pheromones-every-number-of-ticks))
        ;set nest-pheromone-list replace-item i nest-pheromone-list (tmp-nest-pheromone-value * (evaporation-rate-normalized ^ spread-pheromones-every-number-of-ticks))
        set food-pheromone-list replace-item i food-pheromone-list (tmp-food-pheromone-value * (evaporation-rate-normalized))
        set nest-pheromone-list replace-item i nest-pheromone-list (tmp-nest-pheromone-value * (evaporation-rate-normalized))
        recolor-patch
      ]
    ]
    [
      ask patches [
        ;set food-pheromone-list replace-item i food-pheromone-list (tmp-food-pheromone-value * (evaporation-rate-normalized ^ spread-pheromones-every-number-of-ticks))
        ;set nest-pheromone-list replace-item i nest-pheromone-list (tmp-nest-pheromone-value * (evaporation-rate-normalized ^ spread-pheromones-every-number-of-ticks))
        set food-pheromone-list replace-item i food-pheromone-list (tmp-food-pheromone-value * (evaporation-rate-normalized))
        set nest-pheromone-list replace-item i nest-pheromone-list (tmp-nest-pheromone-value * (evaporation-rate-normalized))

        ;recolor-patch
        ;color-pheromone-in-patch
      ]
    ]
    set i (i + 1)
  ]
end

;to spread-pheromones-in-world1
;  diffuse-pheromones
;  remove-pheromones-from-patches-with-barriers
;  evaporate-pheromones
;end

to remove-pheromones-from-patches [-patches]
  ask -patches [remove-all-pheromones-from-patch]
end

to remove-pheromones-from-patches-with-barriers
  remove-pheromones-from-patches patches-with-barriers
end

to-report patches-with-barriers
  ;report patches with [patch-has-barrier]
  report -patches-with-barriers
  ;report patch-set [patch-here] of barriers
end

; patch procedure
to remove-all-pheromones-from-patch
  remove-food-pheromone-from-patch
  remove-nest-pheromone-from-patch
end

; patch procedure
to remove-food-pheromone-from-patch
  set food-pheromone-list n-values (length food-pheromone-list) [0]
end

; patch procedure
to remove-nest-pheromone-from-patch
  set nest-pheromone-list n-values (length nest-pheromone-list) [0]
end

;to diffuse-pheromones
;  diffuse-food-pheromones
;  diffuse-nest-pheromones
;end

;to diffuse-food-pheromones
;  let diffusion-rate-normalized (pheromone-diffusion-rate / 100)
;  ask patches [set tmp-pheromone-list-used-for-diffuse food-pheromone-list]
;  ask patches [diffuse-food-pheromones-in-patch diffusion-rate-normalized]
;end

;to diffuse-nest-pheromones
;  let diffusion-rate-normalized (pheromone-diffusion-rate / 100)
;  ask patches [set tmp-pheromone-list-used-for-diffuse nest-pheromone-list]
;  ask patches [diffuse-nest-pheromones-in-patch diffusion-rate-normalized]
;end

; patch procedure
;to diffuse-food-pheromones-in-patch [diffusion-rate-normalized]
;  set food-pheromone-list n-values length food-pheromone-list
;    [nest-source-number -> diffused-value-of-pheromone-for-nest-in-patch nest-source-number diffusion-rate-normalized]
;end

; patch procedure
;to-report diffused-value-of-pheromone-for-nest-in-patch [nest-source-number diffusion-rate-normalized]
;  report ((item nest-source-number tmp-pheromone-list-used-for-diffuse) * (1 - diffusion-rate-normalized)) +
;    ((sum [item nest-source-number tmp-pheromone-list-used-for-diffuse] of neighbors) / 8) * diffusion-rate-normalized
;end

; patch procedure
;to diffuse-nest-pheromones-in-patch [diffusion-rate-normalized]
;  set nest-pheromone-list n-values length nest-pheromone-list
;    [nest-source-number -> diffused-value-of-pheromone-for-nest-in-patch nest-source-number diffusion-rate-normalized]
;end

to evaporate-pheromones
  ask patches [
    set food-pheromone-list map [food-pheromone -> food-pheromone * (100 - pheromone-evaporation-rate) / 100] food-pheromone-list
    set nest-pheromone-list map [nest-pheromone -> nest-pheromone * (100 - pheromone-evaporation-rate) / 100] nest-pheromone-list ]
end

; turtle procedure
to move-ant
  if path-blocked? 0.1 [
    head-in-direction-with-least-amount-of-barriers-closest-to-current-heading ]
  ifelse ant-walking-style = "wiggle" [
    wiggley ]
  [
    ifelse ant-walking-style = "backwards" [
      backwards ]
    [
      ifelse ant-walking-style = "straight" [
        straight ]
      [
        ifelse ant-walking-style = "zig-zag" [
          zigzag ]
        []
]]]
end

; turtle procedure
to head-in-direction-with-least-amount-of-barriers-closest-to-current-heading
  let unblocked-neighbor4-with-minimum-heading-difference min-difference-in-heading (neighbors4 with [not patch-has-barrier])
  if unblocked-neighbor4-with-minimum-heading-difference != nobody [face unblocked-neighbor4-with-minimum-heading-difference]
end

; turtle procedure
to-report min-difference-in-heading [agentset]
  report min-one-of agentset [abs subtract-headings [towards myself] of myself [heading] of myself]
end

; turtle procedure
to wiggle
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
end

;turtle procedure
to wiggley
  wiggle
  move-forward 1
end

to backwards
  move-backward 1
end

;turtle procedure
to straight
  move-forward 1
end

;turtle procedure
to zigzag
  ifelse number-of-ticks-is-even [
    right random 25 ]
  [
    left random 25 ]
  move-forward 1
end

; turtle procedure
to #blocks#zigzag
  if path-blocked? 0.1 [
    head-in-direction-with-least-amount-of-barriers-closest-to-current-heading ]
  ifelse number-of-ticks-is-even [
    right random 25 ]
  [
    left random 25 ]
  move-forward 1
  set-maximum-pheromone-release-depending-on-ants-surroundings
end

; turtle procedure
to #blocks#straight
  if path-blocked? 0.1 [
    head-in-direction-with-least-amount-of-barriers-closest-to-current-heading ]
  move-forward 1
  set-maximum-pheromone-release-depending-on-ants-surroundings
end

; turtle procedure
to #blocks#walk-random [cone-angle-range]
  if path-blocked? 0.1 [
    head-in-direction-with-least-amount-of-barriers-closest-to-current-heading ]
  head-in-random-direction-ahead cone-angle-range
  move-forward 1
  set-maximum-pheromone-release-depending-on-ants-surroundings
end

; turtle procedure
to #blocks#release-food-pheromone
  release-food-pheromone
  decrease-food-pheromone
end

; turtle procedure
to #blocks#release-nest-pheromone
  release-nest-pheromone
  decrease-nest-pheromone
end

; turtle procedure
to set-maximum-pheromone-release-depending-on-ants-surroundings
  if is-ant-standing-on-home-nest [
    set nest-pheromone-released max-pheromone ]
  if is-ant-standing-on-food [
    set food-pheromone-released max-pheromone ]
end

to-report number-of-ticks-is-even
  report ticks mod 2 = 0
end

; turtle procedure
to drop-food
  set amount-of-food-carried 0
  set-color-of-ant-not-carrying-food
  set-shape-of-ant-not-carrying-food
end

; turtle procedure
to set-shape-of-ant-not-carrying-food
  set shape "bug"
  ;set shape "square"
  ;set shape "bug2"
end

; turtle procedure
to set-color-of-ant-not-carrying-food
  set color (nest-source-number-color home-nest-source-number)
end

; turtle procedure
to-report is-ant-standing-on-home-nest
  report any? nests-here with [source-number = [home-nest-source-number] of myself]
  ;report [patch-has-nest] of patch-here
end

; turtle procedure
to return-to-nest
  ifelse is-ant-standing-on-home-nest [
    add-food-to-nest-ant-is-standing-on
    turn-around ]
  [
    carry-food-home ]
end

; turtle-procedure
to add-food-to-nest-ant-is-standing-on
  if is-ant-standing-on-home-nest and is-carrying-food [
    add-food-to-nest nest-source-number-ant-is-on
    drop-food
  ]
end

; turtle-procedure
to add-food-to-nest [-nest-source-number]
  set amount-of-food-in-nests replace-item
    -nest-source-number amount-of-food-in-nests ((item -nest-source-number amount-of-food-in-nests) + amount-of-food-carried)
  on-ant-added-food-to-nest
end

to-report nest-center [-nest-source-number]
  report item -nest-source-number center-of-nests
end

to-report food-source-center-patch [-food-source-number]
  report item -food-source-number center-of-food-sources
end

; turtle-procedure
to-report nest-source-number-ant-is-on
  report [source-number] of one-of nests-here
end

; turtle-procedure
to on-ant-added-food-to-nest
    update-food-count-gfx-overlay-for-nest nest-source-number-ant-is-on
end

to update-food-count-gfx-overlay-for-nest [-nest-source-number]
  ask get-nest-information-gfx-overlay -nest-source-number [
    ;ask food-count-gfx-overlay [set label word "Food: " amount-of-food-in-nest -nest-source-number]
    ask food-count-gfx-overlay [set label word "אוכל: " amount-of-food-in-nest -nest-source-number]
  ]
end

to update-food-count-gfx-overlay-for-food-source [-food-source-number]
  ask get-food-source-information-gfx-overlay -food-source-number [
    ;ask food-count-gfx-overlay [set label word "Food: " amount-of-food-in-nest -nest-source-number]
    ask food-count-gfx-overlay [set label word "אוכל: " food-count-in-food-source -food-source-number]
  ]
end

to-report get-food-source-information-gfx-overlay [-food-source-number]
  report item -food-source-number food-sources-information-gfx-overlay
end

to-report get-nest-information-gfx-overlay [-nest-source-number]
  report item -nest-source-number nests-information-gfx-overlay
end

; patch-procedure
to-report amount-of-food-in-nest [-nest-source-number]
  report item -nest-source-number amount-of-food-in-nests
end

; turtle procedure
to carry-food-home
  release-food-pheromone
  decrease-food-pheromone
  turn-towards-nest
end

; turtle procedure
to turn-towards-nest
  ifelse home-nest-in-neighbor-patch [
    face-towards-neighbor-patch-with-home-nest-with-least-heading-difference ]
  [
    face-in-direction-of-strongest-nest-pheromone
  ]
end

; turtle procedure
to-report home-nest-in-neighbor-patch
  report any? neighbors with [patch-has-home-nest-of-ant myself]
end

; turtle procedure
to face-towards-neighbor-patch-with-home-nest-with-least-heading-difference
  let neighbor-patch-with-home-nest-with-minimum-heading-difference min-difference-in-heading (neighbors with [patch-has-home-nest-of-ant myself])
  if neighbor-patch-with-home-nest-with-minimum-heading-difference != nobody [
    face neighbor-patch-with-home-nest-with-minimum-heading-difference ]
end

to-report patch-has-home-nest-of-ant [-ant]
  report any? nests-here with [source-number = [home-nest-source-number] of -ant]
end

; turtle procedure
to-report is-time-for-ant-to-drop-food-pheromone
    report can-drop-food-pheromone-according-to-pheromone-drop-rate and pheromone-drop-rate > 0
end

; turtle procedure
to-report can-drop-food-pheromone-according-to-pheromone-drop-rate
  report (ticks + pheromone-zero-clock) mod (11 - pheromone-drop-rate) = 0
end

; turtle procedure
to release-food-pheromone
  if is-time-for-ant-to-drop-food-pheromone [
    add-food-phermone-to-patch
  ]
end

; turtle procedure
to decrease-food-pheromone
  set food-pheromone-released food-pheromone-released * ((100 - pheromone-released-decrease-rate) / 100)
end

; turtle procedure
to add-food-phermone-to-patch
  if food-pheromone-here < food-pheromone-released [
    set-food-pheromone-here food-pheromone-released ]
end

; turtle procedure
to-report food-pheromone-here
  report item home-nest-source-number food-pheromone-list
end

; turtle procedure
to set-food-pheromone-here [amount]
  set food-pheromone-list replace-item home-nest-source-number food-pheromone-list amount
end

; turtle procedure
to-report is-ant-standing-on-food
  report [patch-has-food] of patch-here
end

; turtle procedure
to pick-up-food-from-patch
  if is-ant-standing-on-food [
    ;let food-on-patch one-of food-here
    set amount-of-food-carried amount-of-food-carried + 1
    ask patch-here [reduce-food-in-patch 1]
    set-color-of-ant-carrying-food [color-of-food-in-patch] of patch-here
    set-shape-of-ant-carrying-food
    ;ask food-on-patch [die]
  ]
end

; patch procedure
to-report color-of-food-in-patch
  report food-source-number-color food-source-number
end

to-report  get-base-color-of-shade [shade]
  let lowest-shade-of-base-color-that-shade-belongs-to ((int (shade / 10)) * 10)
  let difference-in-value-between-base-color-and-its-lowest-shade 5
  let base-color lowest-shade-of-base-color-that-shade-belongs-to + difference-in-value-between-base-color-and-its-lowest-shade
  report base-color
end

;turtle prcedure
to set-color-of-ant-carrying-food [-color]
  set color -color
end

;turtle prcedure
to set-shape-of-ant-carrying-food
  set shape word "ant-carrying-food-body-color-" nest-source-number-color home-nest-source-number
  ;set shape ant-carrying-food-shape
  ;set shape "square"
  ;set shape "bug new"
  ;set shape "ant-carrying-food-square-1"
end

; patch procedure
to reduce-food-in-patch [amount-to-reduce]
  if amount-to-reduce > 0 [
   let actual-amount-reduced ifelse-value amount-to-reduce > amount-of-food [amount-of-food] [amount-to-reduce]
   set amount-of-food amount-of-food - actual-amount-reduced
   on-food-reduced-from-patch actual-amount-reduced food-source-number
  ]
  ;ask one-of food-here [die]
end

to-report food-count-in-food-source [-food-source-number]
  report item -food-source-number food-count-in-each-food-source
end

; turtle procedure
to turn-around
  rt 180
end

; turtle procedure
to look-for-food
  if is-ant-standing-on-home-nest [
    set nest-pheromone-released max-pheromone ]
  ifelse is-ant-standing-on-food [
    set food-pheromone-released max-pheromone
    pick-up-food-from-patch
    turn-around
    carry-food-home ]
  [
    move-towards-food
    release-nest-pheromone
    decrease-nest-pheromone
  ]
end

; turtle procedure
to move-towards-food
  ifelse neighbor-patch-has-food [
    face-towards-neighbor-patch-with-food-with-least-heading-difference ]
  [
    ifelse ant-can-sense-food-pheromone [
      face-toward-patch-with-strongest-food-pheromone-in-cone-ahead 3 90
      ;face-toward-patch-with-strongest-food-pheromone-left-right-ahead
    ]

    [
      face-toward-patch-with-weakest-nest-pheromone-in-cone-ahead 3 90
      ;face-toward-patch-with-least-amount-of-ants-and-heading-difference-in-cone-ahead 3 90
      ;face-toward-patch-with-weakest-nest-pheromone-left-right-ahead
    ]
  ]
end

; turtle procedure
to face-toward-patch-with-least-amount-of-ants-and-heading-difference-in-cone-ahead [radius angle]
  let patch-with-least-ants-in-cone-ahead min-difference-in-heading ((patches in-cone radius angle) with-min [count ants-here])
  if patch-with-least-ants-in-cone-ahead != nobody [
    face patch-with-least-ants-in-cone-ahead]
end

; turtle procedure
to-report neighbor-patch-has-food
  report any? neighbors with [patch-has-food]
end

; turtle procedure
to face-towards-neighbor-patch-with-food-with-least-heading-difference
  let neighbor-patch-with-food-with-minimum-heading-difference min-difference-in-heading (neighbors with [patch-has-food])
  if neighbor-patch-with-food-with-minimum-heading-difference != nobody [
    face neighbor-patch-with-food-with-minimum-heading-difference ]
end

; turtle procedure
to face-toward-patch-with-weakest-nest-pheromone-in-cone-ahead [radius angle]
  let -patch-with-weakest-nest-pheromone-in-cone-ahead patch-with-weakest-nest-pheromone-in-cone-ahead radius angle
  if -patch-with-weakest-nest-pheromone-in-cone-ahead != nobody [
    face -patch-with-weakest-nest-pheromone-in-cone-ahead ]
end

; turtle procedure
to face-toward-patch-with-weakest-nest-pheromone-left-right-ahead
  let patch-with-weakest-nest-pheromone min-one-of ((patch-set patch-right-and-ahead 45 1 patch-left-and-ahead 45 1 patch-ahead 1) with [not patch-has-barrier]) [nest-pheromone-of-ant myself]
  if patch-with-weakest-nest-pheromone != nobody [
    face patch-with-weakest-nest-pheromone ]
end

; patch procedure
to-report nest-pheromone-of-ant [-ant]
  report item [home-nest-source-number] of -ant nest-pheromone-list
end

; turtle procedure
to-report patch-with-weakest-nest-pheromone-in-cone-ahead [radius angle]
  ;report min-one-of filter-patches-behind-barriers-from-ants-line-of-sight (patches in-cone radius angle) [nest-pheromone]
  ;report min-one-of (patches in-cone radius angle) [nest-pheromone]
  report min-one-of filter-patches-behind-barriers-from-ants-line-of-sight1 (patches in-cone radius angle) [nest-pheromone-of-ant myself]
end

; turtle procedure
to-report filter-patches-behind-barriers-from-ants-line-of-sight [-patches]
  report -patches with [no-barrier-between-ant myself]
end

; patch procedure
to-report no-barrier-between-ant [-ant]
  report not any? (patches-line-intersects (list pxcor pycor) (list [xcor] of -ant [ycor] of -ant)) with [patch-has-barrier]
end

; turtle procedure
to-report filter-patches-behind-barriers-from-ants-line-of-sight1 [-patches]
  let x map [-patch -> heading-and-distance-range-of-patch-from-self -patch] ([self] of (-patches with [patch-has-barrier])) ;[self] of (patches in-cone 3 360 with [patch-has-barrier])
  ifelse not empty? x [
  let heading-and-distance-ranges-of-barrier-patches reduce sentence x
    report (-patches with [not patch-has-barrier]) with [not is-behind-headings-at-distance-from myself heading-and-distance-ranges-of-barrier-patches] ]
  [
    report -patches
  ]
end

; turtle procedure
to-report heading-and-distance-range-of-patch-from-self [-patch]
  let distance-to-patch distance -patch
  let -heading-to-corners-of-patch heading-to-corners-of-patch -patch
  let min-heading-to-corner min -heading-to-corners-of-patch
  let max-heading-to-corner max -heading-to-corners-of-patch
  let heading-0-passes-through-patch (max-heading-to-corner - min-heading-to-corner) >= 180
  ifelse heading-0-passes-through-patch [
    report (list
      (list (min (filter [-heading -> -heading >= 270] -heading-to-corners-of-patch)) 360 distance-to-patch)
      (list 0 (max (filter [-heading -> -heading <= 90] -heading-to-corners-of-patch)) distance-to-patch) )
    ]
  [
    report (list (list min-heading-to-corner max-heading-to-corner distance-to-patch) )
  ]
end

; turtle procedure
to-report heading-to-corners-of-patch [-patch]
  report map [corner-point-of-patch -> towardsxy first corner-point-of-patch last corner-point-of-patch] ([corner-points-of-patch] of -patch)
end

; patch procedure
to-report corner-points-of-patch
  report (list
    (list (pxcor - 0.5) (pycor + 0.5))
    (list (pxcor + 0.5) (pycor + 0.5))
    (list (pxcor - 0.5) (pycor - 0.5))
    (list (pxcor + 0.5) (pycor - 0.5)) )
end

; patch procedure
to-report is-behind-headings-at-distance-from [-turtle heading-and-distance-ranges]
  let distance-from-turtle [distance myself] of -turtle
  ifelse distance-from-turtle > 0 [
    let heading-from-turtle [towards myself] of -turtle
    report not empty? filter
      [
        heading-and-distance-range ->
        (distance-from-turtle > item 2 heading-and-distance-range) and
        (heading-from-turtle > item 0 heading-and-distance-range) and
        (heading-from-turtle < item 1 heading-and-distance-range)
      ] heading-and-distance-ranges ]
  [
    report false
  ]
end

;turtle-procedure
to release-nest-pheromone
  if is-time-for-ant-to-drop-nest-pheromone [
    add-nest-phermone-to-patch
  ]
end

;turtle-procedure
to decrease-nest-pheromone
  set nest-pheromone-released nest-pheromone-released * ((100 - pheromone-released-decrease-rate) / 100)
end

; turtle procedure
to-report is-time-for-ant-to-drop-nest-pheromone
    report can-drop-nest-pheromone-according-to-pheromone-drop-rate and pheromone-drop-rate > 0
end

to-report can-drop-nest-pheromone-according-to-pheromone-drop-rate
  report (ticks + pheromone-zero-clock) mod (11 - pheromone-drop-rate) = 0
end

; turtle procedure
to add-nest-phermone-to-patch
  if nest-pheromone-here < nest-pheromone-released [
    set-nest-pheromone-here nest-pheromone-released ]
end

; turtle procedure
to-report nest-pheromone-here
  report item home-nest-source-number nest-pheromone-list
end

; turtle procedure
to set-nest-pheromone-here [amount]
  set nest-pheromone-list replace-item home-nest-source-number nest-pheromone-list amount
end

; turtle procedure
to pheromone-driven
    if ant-can-sense-food-pheromone [
      face-in-direction-of-strongest-food-pheromone ]
end

; turtle procedure
to-report ant-can-sense-food-pheromone
  ;report true
  ;report (food-pheromone >= 0.05) and (food-pheromone < 2)
  report (food-pheromone-here >= max-pheromone * food-sniff-sensitivity-lower-threshold)
end

; turtle procedure
;to ant-after-ant
;  ; look in cone of about 90 degrees  -
;  ; if there are ants there that is less than x away, choose one - in-cone vision-radius vision-angle in-cone 15 90
;  ; change direction slightly in that ant's direction
;  if ticks > 20 [
;    ifelse not is-following-another-ant [
;      choose-ant-to-follow ]
;    [
;      head-in-direction-of-ant-it-is-following
;      keep-distance-between-flockmates ]
;  ]
;end

; turtle-procedure
;to keep-distance-between-flockmates
;  if has-flockmates [
;    separate-from-nearest-flockmate ]
;end

; turtle-procedure
;to separate-from-nearest-flockmate
;    find-nearest-flockmate
;    if is-too-close-to-nearest-flockmate [
;      head-away-from-nearest-flockmate ]
;end

; turtle-procedure
;to-report is-too-close-to-nearest-flockmate
;  report distance nearest-neighbor < minimum-separation
;end

; turtle procedure
;to-report has-flockmates
;  find-flockmates
;  report any? flockmates
;end

;turtle procedure
;to head-in-direction-of-ant-it-is-following
;  set heading towards leader
;end

; turtle procedure
;to-report is-following-another-ant
;  report not (leader = nobody)
;end

; turtle procedure
;to choose-ant-to-follow
;  set leader one-of other ants in-cone 15 90
;end

; turtle procedure
;to head-away-from-nearest-flockmate
;  turn-away-from nearest-neighbor max-separate-turn
;end

; turtle procedure
to turn-away-from [ant-to-turn-away-from maximum-angle-for-turn]
  let heading-of-ant-to-turn-away-from [heading] of ant-to-turn-away-from
  turn-at-most (subtract-headings heading heading-of-ant-to-turn-away-from) maximum-angle-for-turn
end

; turtle procedure
to turn-at-most [turn max-turn]
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end

; turtle procedure
;to find-flockmates
;  set flockmates other ants in-radius radius-ant-searches-for-flockmates
;end

; turtle procedure
;to find-nearest-flockmate
;  set nearest-neighbor min-one-of flockmates [distance myself]
;end

; turtle procedure
to face-in-direction-of-strongest-food-pheromone
  face-toward-patch-with-strongest-food-pheromone-in-cone-ahead 3 90
end

; turtle procedure
to face-toward-patch-with-strongest-food-pheromone-in-cone-ahead [radius angle]
  let -patch-with-strongest-food-pheromone-in-cone-ahead patch-with-strongest-food-pheromone-in-cone-ahead radius angle
  if -patch-with-strongest-food-pheromone-in-cone-ahead != nobody [
    face -patch-with-strongest-food-pheromone-in-cone-ahead ]
end

; turtle procedure
to face-toward-patch-with-strongest-food-pheromone-left-right-ahead
  let patch-with-strongest-food-pheromone max-one-of ((patch-set patch-right-and-ahead 45 1 patch-left-and-ahead 45 1 patch-ahead 1) with [not patch-has-barrier]) [food-pheromone-of-ant myself]
  if patch-with-strongest-food-pheromone != nobody [
    face patch-with-strongest-food-pheromone ]
end

; patch procedure
to-report food-pheromone-of-ant [-ant]
  report item [home-nest-source-number] of -ant food-pheromone-list
end

; turtle procedure
to-report patch-with-strongest-food-pheromone-in-cone-ahead [radius angle]
  ;report max-one-of filter-patches-behind-barriers-from-ants-line-of-sight (patches in-cone radius angle) [food-pheromone]
  ;report max-one-of (patches in-cone radius angle) [food-pheromone]
  report max-one-of filter-patches-behind-barriers-from-ants-line-of-sight1 (patches in-cone radius angle) [food-pheromone-of-ant myself]
end

;turtle procedure
to-report barrier-ahead? [-distance]
  report not empty? intersection-points-with-barriers-ahead -distance
end

;turtle procedure
to-report path-blocked? [-distance]
  report (barrier-ahead? -distance) or (not can-move? 1)
end

; turtle procedure
to-report intersection-points-with-barriers-ahead [-distance]
  report filter [point -> point-is-on-barrier point] intersections-with-patch-borders self-point point-ahead -distance
end

; turtle procedure
to-report self-point
  report (list xcor ycor)
end

; turtle procedre
to-report point-ahead [-distance]
  report (list (xcor + (dx * -distance)) (ycor + (dy * -distance)))
end

; turtle procedure
to head-in-random-direction-ahead [angle]
  set heading heading + random-angle-offset-from-center-angle-of-cone angle
end

to-report random-angle-offset-from-center-angle-of-cone [cone-angle]
  let max-angle-difference-from-center-angle-of-cone (cone-angle / 2)
  let -random-angle-offset-from-center-angle-of-cone (random cone-angle) - max-angle-difference-from-center-angle-of-cone
  report -random-angle-offset-from-center-angle-of-cone
end

; turtle procedure
to turn-around-and-head-in-random-direction-ahead [angle]
  turn-around
  head-in-random-direction-ahead angle
end

; turtle procedure
to face-in-direction-of-strongest-nest-pheromone
  if ant-can-sense-nest-pheromone [
    face-toward-patch-with-strongest-nest-pheromone-in-cone-ahead 3 90
  ]
end

; turtle procedure
to-report ant-can-sense-nest-pheromone
  report (nest-pheromone-here >= max-pheromone * nest-sniff-sensitivity-lower-threshold)
end

; turtle procedure
to face-toward-patch-with-strongest-nest-pheromone-in-cone-ahead [radius angle]
  let -patch-with-strongest-nest-pheromone-ahead-in-cone patch-with-strongest-nest-pheromone-ahead-in-cone radius angle
  if -patch-with-strongest-nest-pheromone-ahead-in-cone != nobody [
    face -patch-with-strongest-nest-pheromone-ahead-in-cone ]
end

; turtle procedure
to face-toward-patch-with-strongest-nest-pheromone-left-right-ahead
  let patch-with-strongest-nest-pheromone max-one-of ((patch-set patch-right-and-ahead 45 1 patch-left-and-ahead 45 1 patch-ahead 1) with [not patch-has-barrier]) [nest-pheromone-of-ant myself]
  if patch-with-strongest-nest-pheromone != nobody [
    face patch-with-strongest-nest-pheromone ]
end

; turtle procedure
to-report patch-with-strongest-nest-pheromone-ahead-in-cone [radius angle]
  ;report max-one-of filter-patches-behind-barriers-from-ants-line-of-sight (patches in-cone radius angle) [nest-pheromone]
  ;report max-one-of (patches in-cone radius angle) [nest-pheromone]
  report max-one-of filter-patches-behind-barriers-from-ants-line-of-sight1 (patches in-cone radius angle) [nest-pheromone-of-ant myself]
end

;===== MATH ==================

to-report patches-line-intersects [point1 point2]
  report (patch-set patches-at-points-inclusive intersections-with-patch-borders point1 point2
    patch-at-point point1 patch-at-point point2)
end

to-report patches-at-points-inclusive [points]
  report map [point -> patches-at-point-inclusive point] points
end

to-report intersections-with-patch-borders [point1 point2]
  report sentence (points-of-intersection-with-vertical-grid point1 point2) (points-of-intersection-with-horizontal-grid point1 point2)
end

to-report points-of-intersection-with-vertical-grid [point1 point2]
  report map [vertical-grid-xcor -> intersection-of-line-with-vertical-grid-at-xcor point1 point2 vertical-grid-xcor]
             xcor-of-intersecting-vertical-grids point1 point2
end

to-report xcor-of-intersecting-vertical-grids [point1 point2]
  let lowest-xcor-in-line lowest-xcor-of-points point1 point2
  let highest-xcor-in-line highest-xcor-of-points point1 point2
  report steps-in-range-inclusive lowest-xcor-in-line highest-xcor-in-line 1 0.5
end

to-report lowest-xcor-of-points [point1 point2]
  let point1-xcor first point1
  let point2-xcor first point2
  report ifelse-value point1-xcor < point2-xcor [point1-xcor] [point2-xcor]
end

to-report highest-xcor-of-points [point1 point2]
  let point1-xcor first point1
  let point2-xcor first point2
  report ifelse-value point1-xcor > point2-xcor [point1-xcor] [point2-xcor]
end

to-report intersection-of-line-with-vertical-grid-at-xcor [point1 point2 vertical-grid-xcor]
  ifelse is-vertical point1 point2 [
    report point1 ]
  [
    let slope slope-of point1 point2
    let y-intercept y-intercept-of point1 point2
    let intersection-ycor (slope * vertical-grid-xcor) + y-intercept
    report (list vertical-grid-xcor intersection-ycor)
  ]
end

to-report is-vertical [point1 point2]
  report first point1 = first point2
end

to-report points-of-intersection-with-horizontal-grid [point1 point2]
  report map [horizantal-grid-ycor -> intersection-of-line-with-horizontal-grid-at-ycor point1 point2 horizantal-grid-ycor]
             ycor-of-intersecting-horizontal-grids point1 point2
end

to-report ycor-of-intersecting-horizontal-grids [point1 point2]
  let lowest-ycor-in-line lowest-ycor-of-points point1 point2
  let highest-ycor-in-line highest-ycor-of-points point1 point2
  report steps-in-range-inclusive lowest-ycor-in-line highest-ycor-in-line 1 0.5
end

to-report steps-in-range-inclusive [start-inclusive stop-inclusive step offset]
  let adjacent-step-above-start ((ceiling ( (start-inclusive - offset) / step ) ) * step) + offset
  let adjacent-step-below-stop ((floor ( (stop-inclusive - offset) / step ) ) * step) + offset
  let amount-of-steps-in-range ifelse-value (adjacent-step-below-stop - adjacent-step-above-start) >= 0
      [((adjacent-step-below-stop - adjacent-step-above-start) / step) + 1][0]
  report n-values amount-of-steps-in-range [step-index -> adjacent-step-above-start + (step-index * step)]
end

to-report lowest-ycor-of-points [point1 point2]
  let point1-ycor last point1
  let point2-ycor last point2
  report ifelse-value point1-ycor < point2-ycor [point1-ycor] [point2-ycor]
end

to-report highest-ycor-of-points [point1 point2]
  let point1-ycor last point1
  let point2-ycor last point2
  report ifelse-value point1-ycor > point2-ycor [point1-ycor] [point2-ycor]
end

to-report intersection-of-line-with-horizontal-grid-at-ycor [point1 point2 horizantal-grid-ycor]
  ifelse is-horizontal point1 point2 [
    report point1 ]
  [
    ifelse is-vertical point1 point2 [
      report (list first point1 horizantal-grid-ycor)
       ]
    [
      let slope slope-of point1 point2
      let y-intercept y-intercept-of point1 point2
      let intersection-xcor (horizantal-grid-ycor - y-intercept) / slope
      report (list intersection-xcor horizantal-grid-ycor)
    ]
  ]
end

to-report slope-of [point1 point2]
  report (last point2 - last point1) / (first point2 - first point1)
end

to-report y-intercept-of [point1 point2]
  let point1-xcor first point1
  let point1-ycor last point1
  let slope slope-of point1 point2
  report point1-ycor - (slope * point1-xcor)
end

to-report is-horizontal [point1 point2]
  report last point1 = last point2
end

to-report patches-at-point-inclusive [point]
  ifelse point-is-corner-of-patch-border point [
    report all-patches-with-grid-corner-point point ]
  [
    ifelse point-is-on-horizontal-border-of-a-patch point [
      report patches-above-and-below-point-on-horizontal-patch-border point ]
    [
      if point-is-on-vertical-border-of-a-patch point [
        report patches-right-and-left-of-point-on-vertical-patch-border point]
    ]
  ]
end

to-report all-patches-with-grid-corner-point [point]
 report (patch-set patches-right-and-left-of-point-on-vertical-patch-border list (first point) (last point + 0.5)
                   patches-right-and-left-of-point-on-vertical-patch-border list (first point) (last point - 0.5))
end

to-report point-is-corner-of-patch-border [point]
  report point-is-on-horizontal-border-of-a-patch point and point-is-on-vertical-border-of-a-patch point
end

to-report point-is-on-horizontal-border-of-a-patch [point]
  report (last point + 0.5) mod 1 = 0
end

to-report patches-above-and-below-point-on-horizontal-patch-border [point]
  report (patch-set patch-at-point list (first point) (last point + 0.5)
                    patch-at-point list (first point) (last point - 0.5))
end

to-report patches-right-and-left-of-point-on-vertical-patch-border [point]
  report (patch-set patch-at-point list (first point + 0.5) (last point)
                    patch-at-point list (first point - 0.5) (last point))
end

to-report point-is-on-vertical-border-of-a-patch [point]
report (first point + 0.5) mod 1 = 0
end

to-report patch-at-point [point]
  report patch first point last point
end

;========= Save/Load World =============

to save-world-to-file
  ;let file-path-save-world user-new-file
  ;if is-string? file-path-save-world [
  ;  export-world file-path-save-world ]
  let file-name user-input "איזה שם לתת לקובץ?"
  export-world (word file-name)
end

to load-world-from-file
;  let file-path-load-world user-file
;  if is-string? file-path-load-world [
;    import-world file-path-load-world
;    set last-world-file-that-was-loaded file-path-load-world ]
  ;let text fetch:user-file ;[text ->
  fetch:user-file-async [text ->
    if not (text = false) [
      carefully [
        import-a:world text
      ] [
        user-message "אין אפשרות לטעון את הקובץ"
      ]
    ]
  ]
end

;to reload-last-world-that-was-loaded-from-file
;  let tmp last-world-file-that-was-loaded
;  ; need to fix this code written badly
;  if (is-string? last-world-file-that-was-loaded) and (file-exists? last-world-file-that-was-loaded) and (last-world-file-that-was-loaded != "") [
;    import-world last-world-file-that-was-loaded
;    set last-world-file-that-was-loaded tmp]
;end

;to-report get-last-world-file-that-was-loaded
;  ifelse is-string? last-world-file-that-was-loaded [
;    report last-world-file-that-was-loaded ]
;  [
;    report ""
;  ]
;end
;=======================================

;====== Background ================================

to set-background-image-to-default
  set background-type-being-displayed "default"
  import-a:drawing default-background-image-base64
end

to-report default-background-image-base64
  report 0
end
; --- NETTANGO BEGIN ---

; This block of code was added by the NetTango builder.  If you modify this code
; and re-import it into the NetTango builder you may lose your changes or need
; to resolve some errors manually.

; If you do not plan to re-import the model into the NetTango builder then you
; can safely edit this code however you want, just like a normal NetLogo model.

; Code for setup
to #blocks#create-world
  create-circular-nest-with-ants 0 0 4 100
  create-circular-mound-food-source 21 0 5
  create-circular-mound-food-source -21 -21 5
  create-circular-mound-food-source -28 28 5
end

; Code for go
to #blocks#advance-ants-1-turn
  ask ants
  [
    if not is-carrying-food
    [
      if is-ant-standing-on-food
      [
      ]
      if not is-ant-standing-on-food
      [
      ]
    ]
    if is-carrying-food
    [
      if is-ant-standing-on-home-nest
      [
      ]
      if not is-ant-standing-on-home-nest
      [
      ]
    ]
    #blocks#zigzag
  ]
end
; --- NETTANGO END ---
@#$#@#$#@
GRAPHICS-WINDOW
440
10
1150
720
-1
-1
10
1
10
1
1
1
0
0
0
1
-35
35
-35
35
1
1
1
ticks
30

BUTTON
1386
27
1480
96
איתחול
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1285
27
1378
96
הרצה
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
0
10
433
323
כמות אוכל במאגרים
זמן
אוכל
0
50
0
120
true
true
"" ""
PENS


BUTTON
1367
161
1463
194
תצפית על נמלה
watch ant (min [who] of ants)
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1467
161
1563
194
מעקב על נמלה
ride ant (min [who] of ants)
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1404
201
1523
234
הפסק מעקב\תצפית
reset-perspective
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1207
151
1312
184
הפעל מברשת
activate-brush
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
1185
423
1324
456
brush-size
brush-size
1
20
3
1
1
NIL
HORIZONTAL

BUTTON
1263
271
1321
304
אוכל
set-brush-type \"food\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1198
271
1255
304
מחסום
set-brush-type \"barrier\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1197
314
1255
347
נמלים
set-brush-type \"ant\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1263
314
1321
347
קן
set-brush-type \"nest\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1232
129
1289
161
מברשת
15
0
1

INPUTBOX
162
641
281
701
food-pheromone-color
65
1
0
Color

INPUTBOX
36
641
155
701
nest-pheromone-color
115
1
0
Color

BUTTON
1403
245
1525
278
נמלה משאירה שביל
set-brush-type \"trail\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1403
488
1522
521
נקה שביל נמלים
clear-ant-trails
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1404
419
1523
452
הפסק סימון שבילים
ask ants [pen-up]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1182
27
1276
96
התקדם צעד 1
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1401
334
1523
367
סימון נמלה בעיגול
set-brush-type \"mark\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
288
641
384
701
barrier-color
45
1
0
Color

MONITOR
1250
676
1300
721
Nest
current-nest-displaying-pheromone
17
1
11

SLIDER
1314
679
1506
712
pheromone-transparency
pheromone-transparency
0
100
100
1
1
NIL
HORIZONTAL

PLOT
0
329
433
575
כמות אוכל בקנים
זמן
אוכל
0
10
0
10
true
true
"" ""
PENS


BUTTON
1181
196
1252
234
צביעה
user-set-brush-to-draw
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1265
196
1334
234
מחיקה
user-set-brush-to-erase
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1259
486
1314
519
ריבוע
set-brush-shape \"square\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1191
486
1246
519
עיגול
set-brush-shape \"circle\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1217
402
1304
420
גודל מברשת
14
0
1

TEXTBOX
1214
463
1298
481
צורת מברשת
14
0
1

TEXTBOX
1186
246
1336
264
מה לצייר עם המברשת
14
0
1

TEXTBOX
1402
132
1552
152
מעקב אחרי נמלים
15
0
1

TEXTBOX
167
591
317
611
הגדרת צבעים
15
0
1

TEXTBOX
315
622
363
643
מחסום
14
0
1

TEXTBOX
182
621
260
639
פרומון אוכל
14
0
1

TEXTBOX
70
622
220
640
פרומון קן
14
0
1

TEXTBOX
1398
281
1539
321
*יש לצייר בעזרת המברשת על הנמלים שישאירו שביל איפה שהם הולכים
11
0
1

TEXTBOX
1392
370
1542
412
*יש לצייר בעזרת המברשת על הנמלים על מנת לסמן אותם בעיגול
11
0
1

TEXTBOX
1341
118
1356
532
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1172
524
1345
542
-----------------------------------------------
11
0
1

TEXTBOX
1173
112
1345
130
-------------------------------------------------------------
11
0
1

TEXTBOX
1171
117
1186
532
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1571
117
1586
533
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1353
117
1368
533
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1354
112
1575
130
----------------------------------------------------------------------
11
0
1

TEXTBOX
1354
525
1575
543
-------------------------------------------------------------
11
0
1

TEXTBOX
29
706
394
724
----------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
30
574
396
592
---------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
28
578
43
716
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
390
579
405
716
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1405
454
1535
482
*כל הנמלים יפסיקו לסמן את השביל שלהם
11
0
1

TEXTBOX
1279
552
1429
570
הגדרת פרומונים
14
0
1

TEXTBOX
1365
575
1453
593
הצגת פרומונים
12
0
1

TEXTBOX
1372
654
1472
672
נראות פרומונים
12
0
1

BUTTON
1413
598
1468
631
הצג
show-pheromones
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1353
598
1408
631
הסתר
hide-pheromones
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1255
598
1318
631
אוכל
display-food-pheromone
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1183
598
1246
631
קן
display-nest-pheromone
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1203
638
1290
668
מציג פרומונים של קן מספר:
12
0
1

BUTTON
1179
676
1243
722
החלף קן
display-pheromones-of-another-nest
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1198
576
1348
594
הצג פרומונים מסוג
12
0
1

TEXTBOX
1171
538
1518
556
---------------------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
1171
725
1516
744
---------------------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
1513
543
1528
733
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1170
543
1185
733
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1788
492
1938
510
NIL
11
0
1

TEXTBOX
1173
10
1493
28
------------------------------------------------------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
1173
99
1492
117
------------------------------------------------------------------------------------------------------------------------------------------------
11
0
1

TEXTBOX
1490
15
1505
107
|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

TEXTBOX
1171
15
1186
107
|\n|\n|\n|\n|\n|\n|\n|\n|
11
0
1

BUTTON
1263
356
1332
389
פרומון אוכל
set-brush-type \"food-pheromone\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1186
356
1255
389
פרומון קן
set-brush-type \"nest-pheromone\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
811
740
878
773
שמור
save-world-to-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
723
740
788
773
פתח
load-world-from-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1
@#$#@#$#@
## WHAT IS IT?

In this project, a colony of ants forages for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

## HOW IT WORKS

When an ant finds a piece of food, it carries the food back to the nest, dropping a chemical as it moves. When other ants "sniff" the chemical, they follow the chemical toward the food. As more ants carry food to the nest, they reinforce the chemical trail.

## HOW TO USE IT

Click the SETUP button to set up the ant nest (in violet, at center) and three piles of food. Click the GO button to start the simulation. The chemical is shown in a green-to-white gradient.

The EVAPORATION-RATE slider controls the evaporation rate of the chemical. The DIFFUSION-RATE slider controls the diffusion rate of the chemical.

If you want to change the number of ants, move the POPULATION slider before pressing SETUP.

## THINGS TO NOTICE

The ant colony generally exploits the food source in order, starting with the food closest to the nest, and finishing with the food most distant from the nest. It is more difficult for the ants to form a stable trail to the more distant food, since the chemical trail has more time to evaporate and diffuse before being reinforced.

Once the colony finishes collecting the closest food, the chemical trail to that food naturally disappears, freeing up ants to help collect the other food sources. The more distant food sources require a larger "critical number" of ants to form a stable trail.

The consumption of the food is shown in a plot.  The line colors in the plot match the colors of the food piles.

## EXTENDING THE MODEL

Try different placements for the food sources. What happens if two food sources are equidistant from the nest? When that happens in the real world, ant colonies typically exploit one source then the other (not at the same time).

In this project, the ants use a "trick" to find their way back to the nest: they follow the "nest scent." Real ants use a variety of different approaches to find their way back to the nest. Try to implement some alternative strategies.

The ants only respond to chemical levels between 0.05 and 2.  The lower limit is used so the ants aren't infinitely sensitive.  Try removing the upper limit.  What happens?  Why?

In the `uphill-chemical` procedure, the ant "follows the gradient" of the chemical. That is, it "sniffs" in three directions, then turns in the direction where the chemical is strongest. You might want to try variants of the `uphill-chemical` procedure, changing the number and placement of "ant sniffs."

## NETLOGO FEATURES

The built-in `diffuse` primitive lets us diffuse the chemical easily without complicated code.

The primitive `patch-right-and-ahead` is used to make the ants smell in different directions without actually turning.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds."  Cambridge, MA: MIT Press.  Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 1998.

<!-- 1997 1998 MIT -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

ant carrying food
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Circle -16777216 true false 123 3 85
Polygon -16777216 true false 165 0 120 15 90 45 120 75 165 90 165 0
Polygon -7500403 true true 165 15 165 15 105 45 150 75 165 75 195 60 195 45 195 30 165 15 150 15 105 45
Polygon -7500403 true true 105 45 120 60 150 75 150 15 120 30 105 45
Polygon -8630108 true false 195 30
Circle -7500403 true true 135 15 60

ant carrying food 2
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Circle -16777216 true false 123 3 85
Polygon -16777216 true false 165 0 120 15 90 45 120 75 165 90 165 0
Polygon -7500403 true true 165 15 165 15 105 45 150 75 165 75 195 60 195 45 195 30 165 15 150 15 105 45
Polygon -7500403 true true 105 45 120 60 150 75 150 15 120 30 105 45
Polygon -8630108 true false 195 30
Circle -7500403 true true 135 15 60
Rectangle -16777216 true false 90 0 210 120
Rectangle -7500403 true true 105 15 195 105

ant carrying food 3
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Polygon -8630108 true false 195 30
Rectangle -7500403 true true 105 15 195 105
Rectangle -16777216 false false 105 15 195 105

ant with food
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30
Rectangle -11221820 true false 135 105 165 270

ant with food 3
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Circle -7500403 true true 123 3 85
Polygon -7500403 true true 165 0 120 15 90 45 120 75 165 90 165 0
Polygon -7500403 true true 165 15 165 15 105 45 150 75 165 75 195 60 195 45 195 30 165 15 150 15 105 45
Polygon -7500403 true true 105 45 120 60 150 75 150 15 120 30 105 45
Polygon -8630108 true false 195 30
Circle -7500403 true true 135 15 60

ant with food 4
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Rectangle -16777216 true false 120 90 180 285
Rectangle -7500403 true true 135 105 165 270

ant with food1
true
8
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Rectangle -11221820 true true 135 105 165 270

ant-carrying-food-body-color-105
true
0
Circle -13345367 true false 110 127 80
Circle -13345367 true false 110 75 80
Circle -13345367 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-115
true
0
Circle -8630108 true false 110 127 80
Circle -8630108 true false 110 75 80
Circle -8630108 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-125
true
0
Circle -5825686 true false 110 127 80
Circle -5825686 true false 110 75 80
Circle -5825686 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-135
true
0
Circle -2064490 true false 110 127 80
Circle -2064490 true false 110 75 80
Circle -2064490 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-15
true
0
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Circle -2674135 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-25
true
0
Circle -955883 true false 110 127 80
Circle -955883 true false 110 75 80
Circle -955883 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-35
true
0
Circle -6459832 true false 110 127 80
Circle -6459832 true false 110 75 80
Circle -6459832 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-45
true
0
Circle -1184463 true false 110 127 80
Circle -1184463 true false 110 75 80
Circle -1184463 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-5
true
0
Circle -7500403 true false 110 127 80
Circle -7500403 true false 110 75 80
Circle -7500403 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-55
true
0
Circle -10899396 true false 110 127 80
Circle -10899396 true false 110 75 80
Circle -10899396 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-65
true
0
Circle -13840069 true false 110 127 80
Circle -13840069 true false 110 75 80
Circle -13840069 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-75
true
0
Circle -14835848 true false 110 127 80
Circle -14835848 true false 110 75 80
Circle -14835848 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-85
true
0
Circle -11221820 true false 110 127 80
Circle -11221820 true false 110 75 80
Circle -11221820 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-body-color-95
true
0
Circle -13791810 true false 110 127 80
Circle -13791810 true false 110 75 80
Circle -13791810 true false 96 182 108
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-seed
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Circle -16777216 true false 123 3 85
Polygon -16777216 true false 165 0 105 15 75 45 105 75 165 90 165 0
Polygon -7500403 true true 165 15 165 15 105 45 150 75 165 75 195 60 195 45 195 30 165 15 150 15 105 45
Polygon -7500403 true true 90 45 105 60 150 75 150 15 105 30 105 30
Polygon -8630108 true false 195 30
Circle -7500403 true true 135 15 60
Polygon -7500403 true true 105 30 135 15 150 15 180 15 195 30 195 60 180 75 150 75 135 75 105 60 120 30

ant-carrying-food-seed-2
true
0
Circle -2674135 true false 110 127 80
Polygon -16777216 true false 195 180 120 165 60 135 15 90 60 45 120 15 195 0 240 15 270 45 270 135 240 165 195 180
Circle -16777216 true false 110 5 170
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 75 80
Polygon -8630108 true false 195 30
Circle -7500403 true true 120 15 150
Polygon -7500403 true true 195 15 150 15 105 30 60 60 30 90 60 120 105 150 150 165 195 165 195 15
Polygon -8630108 true false 195 0
Polygon -8630108 true false 195 0 135 15
Polygon -8630108 true false 210 0

ant-carrying-food-seed-3
true
0
Circle -2674135 true false 110 127 80
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 75 80
Polygon -8630108 true false 195 30
Circle -16777216 true false 120 15 150
Polygon -16777216 true false 195 15 150 15 105 30 60 60 30 90 60 120 105 150 150 165 195 165 195 15
Polygon -8630108 true false 195 0
Polygon -8630108 true false 195 0 135 15
Polygon -8630108 true false 210 0
Circle -7500403 true true 133 28 122
Polygon -7500403 true true 195 30 150 30 105 45 60 75 45 90 75 120 105 135 150 150 195 150 195 45

ant-carrying-food-seed-4
true
0
Polygon -8630108 true false 255 60 270 90 255 120 225 150 255 60
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Polygon -8630108 true false 225 30 180 15 150 15 120 30 90 45 90 45 45 90 90 135 120 150 150 165 180 165 225 150 255 60 225 30
Circle -2674135 true false 96 182 108
Polygon -8630108 true false 195 30
Polygon -8630108 true false 195 0
Polygon -8630108 true false 195 0 135 15
Polygon -8630108 true false 210 0
Circle -8630108 true false 133 28 122
Polygon -13840069 true false 195 30
Polygon -13840069 true false 195 45
Circle -13840069 true false 141 36 108
Polygon -13840069 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30

ant-carrying-food-seed-5
true
0
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Circle -2674135 true false 96 182 108
Polygon -8630108 true false 195 30
Polygon -8630108 true false 195 0
Polygon -8630108 true false 195 0 135 15
Polygon -8630108 true false 210 0
Polygon -13840069 true false 195 30
Polygon -13840069 true false 195 45
Circle -16777216 true false 141 36 108
Polygon -16777216 true false 195 30 150 30 90 60 60 90 90 120 150 150 195 150 225 135 240 90 225 45 195 30
Circle -7500403 true true 150 45 90
Polygon -7500403 true true 210 45 165 45 150 45 90 75 75 90 90 105 150 135 195 135 240 105 240 75 210 45

ant-carrying-food-square
true
0
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 127 80
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 80 30
Line -2674135 false 150 100 220 30
Polygon -8630108 true false 195 30
Rectangle -7500403 true true 90 15 210 135
Rectangle -16777216 false false 90 15 210 135

ant-carrying-food-square-1
true
0
Line -16777216 false 75 30 135 90
Line -16777216 false 75 30 165 105
Circle -16777216 true false 103 73 92
Circle -16777216 true false 90 180 120
Circle -16777216 true false 103 118 92
Circle -2674135 true false 96 182 108
Circle -2674135 true false 110 75 80
Line -2674135 false 150 100 75 30
Line -2674135 false 150 100 225 30
Polygon -8630108 true false 195 30
Circle -2674135 true false 110 127 80
Rectangle -16777216 false false 90 15 210 135
Rectangle -7500403 true true 90 15 210 135

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

brush-cursor-draw
false
6
Polygon -1184463 true false 75 210 210 60 225 60 255 90 255 105 120 255 75 210
Polygon -2674135 true false 75 210 45 285 120 255 60 240
Line -16777216 false 255 90 255 90
Line -16777216 false 255 90 105 255
Line -16777216 false 225 60 60 240
Line -16777216 false 255 105 120 255
Line -16777216 false 210 60 75 210
Line -16777216 false 210 60 225 60
Line -16777216 false 225 60 255 90
Line -16777216 false 255 90 255 105
Polygon -2674135 true false 120 255 75 210 60 240 90 270 120 255
Line -16777216 false 75 210 120 255
Line -16777216 false 75 210 60 240
Line -16777216 false 90 270 120 255

brush-cursor-draw2
false
7
Polygon -13345367 true false 195 45 225 15 255 15 285 45 285 45 285 75 255 105 255 75 225 45 195 45
Polygon -16777216 false false 195 45 225 15 255 15 285 45 285 75 255 105 255 75 225 45 195 45
Polygon -1184463 true false 195 45 225 45 255 75 255 105 75 270 75 240 45 210 45 210 15 210 195 45
Polygon -16777216 false false 15 210 195 45 225 45 255 75 255 105 75 270 75 240 45 210 15 210
Line -16777216 false 225 45 45 210
Line -16777216 false 255 75 75 240
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 15 210 0 285 75 270 75 240 45 210 15 210
Polygon -16777216 false false 15 210 0 285 75 270 75 240 45 210 15 210
Line -16777216 false 225 45 255 15
Line -16777216 false 255 75 285 45

brush-cursor-draw3
false
7
Polygon -1184463 true false 225 15 255 15 285 45 285 75 105 240 105 210 75 180 75 180 45 180 225 15
Polygon -16777216 false false 45 180 225 15 255 15 285 45 285 75 105 240 105 210 75 180 45 180
Line -16777216 false 255 15 75 180
Line -16777216 false 285 45 105 210
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 45 180 15 270 105 240 105 210 75 180 45 180
Polygon -16777216 false false 45 180 15 270 105 240 105 210 75 180 45 180

brush-cursor-draw4
false
7
Polygon -1184463 true false 225 15 255 15 285 45 285 75 105 240 105 210 75 180 75 180 45 180 225 15
Polygon -16777216 false false 45 180 225 15 255 15 285 45 285 75 105 240 105 210 75 180 45 180
Line -16777216 false 255 15 75 180
Line -16777216 false 285 45 105 210
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 45 180 30 255 105 240 105 210 75 180 45 180
Polygon -16777216 false false 45 180 30 255 105 240 105 210 75 180 45 180

brush-cursor-draw5
false
7
Polygon -1184463 true false 225 15 255 15 285 45 285 75 90 255 90 225 60 195 60 195 30 195 225 15
Polygon -16777216 false false 30 195 225 15 255 15 285 45 285 75 90 255 90 225 60 195 30 195
Line -16777216 false 255 15 60 195
Line -16777216 false 285 45 90 225
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 30 195 15 270 90 255 90 225 60 195 30 195
Polygon -16777216 false false 30 195 15 270 90 255 90 225 60 195 30 195

brush-cursor-draw6
false
7
Polygon -1184463 true false 195 45 225 45 255 75 255 105 75 270 75 240 45 210 45 210 15 210 195 45
Polygon -16777216 false false 15 210 195 45 225 45 255 75 255 105 75 270 75 240 45 210 15 210
Line -16777216 false 225 45 45 210
Line -16777216 false 255 75 75 240
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 15 210 0 285 75 270 75 240 45 210 15 210
Polygon -16777216 false false 15 210 0 285 75 270 75 240 45 210 15 210

brush-cursor-erase
false
0
Polygon -16777216 false false 75 195
Polygon -2064490 true false 30 270 135 270 240 165 225 120 135 120 45 195 30 270
Line -16777216 false 30 270 135 270
Line -16777216 false 135 195 135 270
Line -16777216 false 135 270 240 165
Line -16777216 false 240 165 225 120
Line -16777216 false 135 195 225 120
Line -16777216 false 45 195 135 195
Line -16777216 false 45 195 30 270
Line -16777216 false 45 195 135 120
Line -16777216 false 135 120 225 120

brush-mode-icon-draw
false
6
Rectangle -7500403 true false 0 0 300 300
Polygon -1184463 true false 75 105 225 255 240 255 255 240 255 225 105 75 90 105
Polygon -16777216 false false 75 105 90 105 105 90 105 75 255 225 255 240 105 90 90 105 240 255 255 240 240 255 225 255 75 105
Polygon -2674135 true false 105 75 60 60 75 105 90 105 105 90 105 75
Polygon -2674135 true false 75 60 90 30 120 0 135 0 105 30 90 60 75 60
Polygon -2674135 true false 90 60 105 60 120 30 150 0 120 0
Rectangle -16777216 false false 0 0 300 300
Line -16777216 false 105 75 60 60
Line -16777216 false 75 105 60 60

brush-mode-icon-draw2
false
7
Rectangle -7500403 true false 0 0 300 300
Polygon -1184463 true false 210 30 240 30 270 60 270 90 90 255 90 225 60 195 60 195 30 195 210 30
Polygon -16777216 false false 30 195 210 30 240 30 270 60 270 90 90 255 90 225 60 195 30 195
Line -16777216 false 240 30 60 195
Line -16777216 false 270 60 90 225
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 30 195 15 270 90 255 90 225 60 195 30 195
Polygon -16777216 false false 30 195 15 270 90 255 90 225 60 195 30 195
Rectangle -16777216 false false 0 0 300 300

brush-mode-icon-erase
false
6
Rectangle -7500403 true false 0 0 300 300
Polygon -16777216 false false 75 195
Polygon -2064490 true false 45 225 150 225 255 120 240 75 150 75 60 150 45 225
Line -16777216 false 45 225 150 225
Line -16777216 false 150 150 150 225
Line -16777216 false 150 225 255 120
Line -16777216 false 255 120 240 75
Line -16777216 false 150 150 240 75
Line -16777216 false 60 150 150 150
Line -16777216 false 60 150 45 225
Line -16777216 false 60 150 150 75
Line -16777216 false 150 75 240 75
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-ant
false
6
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false -2 0 298 300
Line -13840069 true 139 87 97 35
Line -13840069 true 155 91 206 32
Line -16777216 false 130 78 94 33
Line -16777216 false 134 76 92 29
Line -16777216 false 167 75 206 30
Line -16777216 false 171 77 207 31
Circle -16777216 true false 111 115 78
Circle -16777216 true false 100 168 100
Circle -16777216 true false 111 65 78
Circle -13840069 true true 114 68 72
Circle -13840069 true true 113 116 74
Circle -13840069 true true 103 171 94

brush-type-icon-barrier
false
6
Rectangle -1 true false 0 0 300 300
Rectangle -13840069 true true 15 225 150 285
Rectangle -13840069 true true 165 225 300 285
Rectangle -13840069 true true 75 150 210 210
Rectangle -13840069 true true 0 150 60 210
Rectangle -13840069 true true 225 150 300 210
Rectangle -13840069 true true 166 75 301 135
Rectangle -13840069 true true 15 75 150 135
Rectangle -13840069 true true 0 0 60 60
Rectangle -13840069 true true 225 0 300 60
Rectangle -13840069 true true 75 0 210 60
Polygon -6459832 true false 123 155 207 261 221 265 234 251 235 238 147 136 123 155
Polygon -7500403 true false 140 147 155 133 149 116 150 109 154 104 168 97 190 91 179 78 154 82 127 93 101 111 88 122 92 129 93 131 91 135 87 136 83 134 78 129 59 145 57 157 78 181 88 187 109 168 104 161 103 154 105 155 105 152 105 152 112 155 116 161
Polygon -16777216 false false 178 79 188 90 152 104 149 108 149 117 155 133 147 139 130 152 115 161 111 154 104 153 102 156 108 167 88 187 78 181 56 155 59 146 76 129 85 137 89 139 92 131 88 122 129 91 156 82 176 78
Polygon -16777216 false false 150 138 234 238 234 252 220 263 206 260 125 157
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-barrier-empty
false
6
Rectangle -1 true false 0 0 300 300
Rectangle -13840069 true true 15 225 150 285
Rectangle -13840069 true true 165 225 300 285
Rectangle -13840069 true true 75 150 210 210
Rectangle -13840069 true true 0 150 60 210
Rectangle -13840069 true true 225 150 300 210
Rectangle -13840069 true true 165 75 300 135
Rectangle -13840069 true true 15 75 150 135
Rectangle -13840069 true true 0 0 60 60
Rectangle -13840069 true true 225 0 300 60
Rectangle -13840069 true true 75 0 210 60
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-food
false
6
Rectangle -7500403 true false 0 0 300 300
Polygon -16777216 true false 170 183 177 150 192 124 218 99 243 124 258 151 264 185
Circle -16777216 true false 169 135 94
Polygon -16777216 true false 32 181 39 148 54 122 80 97 105 122 120 149 126 183
Circle -16777216 true false 32 137 94
Polygon -2674135 true false 37 180 45 146 58 123 80 103 100 123 112 145 121 180
Polygon -6459832 true false 176 182 184 148 197 125 219 105 239 125 251 147 260 182
Circle -2674135 true false 36 141 86
Circle -6459832 true false 173 139 86
Polygon -7500403 true false 120 240
Circle -16777216 true false 101 80 94
Polygon -16777216 true false 101 119 108 86 123 60 149 35 174 60 189 87 195 121
Circle -955883 true false 105 83 86
Polygon -955883 true false 106 118 114 84 127 61 149 41 169 61 181 83 190 118
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-food-pheromone
false
15
Rectangle -7500403 true false 0 0 300 300
Polygon -16777216 true false 247 68 238 54 229 29 231 3 259 5 281 17 296 34
Circle -16777216 true false 241 21 60
Polygon -10899396 true false 219 40 247 89 60 300 0 300 0 240
Polygon -13840069 true false 223 42 244 88 117 225 88 168
Circle -13840069 true false 120 135 0
Polygon -13840069 true false 91 163 137 207 41 303 0 301 0 256
Circle -16777216 true false 47 189 66
Circle -16777216 true false 86 162 50
Circle -2674135 true false 50 192 60
Circle -16777216 true false 184 72 60
Polygon -16777216 true false 187 116 178 102 169 77 171 51 199 53 221 65 236 82
Circle -955883 true false 189 76 52
Polygon -955883 true false 194 117 182 101 173 79 174 55 198 57 219 69 234 87 220 104
Line -2674135 false 136 151 143 116
Line -2674135 false 147 160 183 152
Line -16777216 false 138 149 144 113
Line -16777216 false 133 151 143 115
Line -16777216 false 144 157 185 152
Line -16777216 false 144 162 185 153
Circle -16777216 true false 114 139 46
Circle -2674135 true false 115 141 42
Circle -2674135 true false 88 164 46
Circle -955883 true false 245 25 52
Polygon -955883 true false 254 68 242 52 233 30 234 6 258 8 279 20 294 38 280 55
Polygon -16777216 true false 193 65 184 51 175 26 177 0 205 2 227 14 242 31
Circle -16777216 true false 184 13 60
Circle -16777216 true false 236 68 60
Circle -955883 true false 188 16 52
Polygon -16777216 true false 241 114 232 100 223 75 225 49 253 51 275 63 290 80
Polygon -955883 true false 249 115 237 99 228 77 229 53 253 55 274 67 289 85 275 102
Circle -955883 true false 240 71 52
Polygon -955883 true false 200 65 188 49 179 27 180 3 204 5 225 17 240 35 226 52
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-food-pheromone3
false
15
Rectangle -7500403 true false 1 0 303 300
Polygon -10899396 true false 219 40 247 89 60 300 0 300 0 240
Polygon -13840069 true false 223 42 244 88 117 225 88 168
Circle -13840069 true false 120 135 0
Polygon -13840069 true false 91 163 137 207 41 303 0 301 0 256
Circle -16777216 true false 77 156 66
Circle -16777216 true false 118 132 50
Circle -2674135 true false 80 159 60
Circle -16777216 true false 226 37 60
Polygon -16777216 true false 233 85 224 71 215 46 217 20 245 22 267 34 282 51
Circle -955883 true false 231 41 52
Polygon -955883 true false 240 86 228 70 219 48 220 24 244 26 265 38 280 56 266 73
Line -2674135 false 169 115 176 80
Line -2674135 false 182 131 218 123
Line -16777216 false 171 114 177 78
Line -16777216 false 167 114 177 78
Line -16777216 false 182 128 223 123
Line -16777216 false 182 133 223 124
Circle -16777216 true false 145 110 46
Circle -2674135 true false 147 112 42
Circle -2674135 true false 120 134 46
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-food3
false
6
Rectangle -7500403 true false 0 0 300 300
Circle -16777216 true false 95 75 110
Circle -16777216 true false 72 104 156
Polygon -16777216 true false 221 149 195 101 106 99 80 148
Polygon -16777216 true false 195 105 180 75 165 60 135 60 120 75 105 105 180 90
Circle -16777216 true false 135 45 30
Circle -13840069 true true 90 135 120
Polygon -13840069 true true 120 240 90 210 90 195 90 180 90 150 105 120 120 90 135 75 150 60 165 75 180 90 195 120 210 150 210 165 210 195 210 210 180 240
Polygon -7500403 true false 120 240
Circle -13840069 true true 90 120 120
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-mark
false
6
Rectangle -7500403 true false 0 0 300 300
Circle -1184463 false false 21 21 258
Circle -13840069 true true 105 165 90
Circle -13840069 true true 118 118 62
Circle -13840069 true true 118 73 62
Line -13840069 true 135 90 105 45
Line -13840069 true 195 45 165 90
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-nest
false
0
Rectangle -6459832 true false 0 0 300 300
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255
Rectangle -16777216 false false 0 0 300 300
Line -955883 false 250 76 279 74
Circle -16777216 true false 135 98 66
Circle -16777216 true false 203 54 46
Circle -16777216 true false 173 77 50
Circle -955883 true false 175 79 46
Line -16777216 false 231 58 242 26
Line -16777216 false 234 60 244 26
Line -16777216 false 248 78 281 75
Line -16777216 false 248 74 282 74
Circle -955883 true false 138 101 60
Line -955883 false 233 58 243 27
Circle -955883 true false 205 56 42
Circle -7500403 true true 35 146 130
Circle -6459832 true false 43 154 112
Circle -16777216 true false 58 168 84
Rectangle -16777216 true false 92 77 99 188
Polygon -13345367 true false 91 77 39 107 91 130 91 77

brush-type-icon-nest-empty
false
0
Rectangle -6459832 true false 0 0 300 300
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-nest-pheromone
false
6
Rectangle -7500403 true false 0 0 315 301
Rectangle -16777216 false false 0 -1 300 300
Line -13840069 true 258 72 287 70
Line -16777216 false 237 51 248 19
Line -16777216 false 241 52 250 18
Line -16777216 false 256 74 290 71
Line -16777216 false 254 69 289 70
Line -13840069 true 238 53 248 22
Polygon -8630108 true false 47 208 161 98 205 146 95 248
Circle -16777216 true false 146 94 66
Circle -16777216 true false 185 73 50
Circle -13840069 true true 149 97 60
Circle -8630108 true false 16 165 116
Circle -8630108 true false 28 176 94
Circle -16777216 true false 35 183 80
Rectangle -16777216 true false 68 107 75 218
Polygon -13345367 true false 65 106 13 136 65 159 65 106
Circle -16777216 true false 213 48 46
Circle -13840069 true true 187 75 46
Circle -13840069 true true 215 50 42

brush-type-icon-nest-pheromone2
false
0
Rectangle -6459832 true false 0 0 300 300
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255
Rectangle -16777216 false false 0 -1 300 299
Line -955883 false 258 66 287 64
Line -16777216 false 246 48 257 16
Line -16777216 false 249 50 258 16
Line -16777216 false 257 67 290 64
Line -16777216 false 256 63 290 63
Line -955883 false 247 50 257 19
Polygon -8630108 true false 48 206 169 90 216 138 96 246
Circle -16777216 true false 154 86 66
Circle -16777216 true false 193 66 50
Circle -955883 true false 157 89 60
Circle -8630108 true false 16 165 116
Circle -6459832 true false 27 176 94
Circle -16777216 true false 34 183 80
Rectangle -16777216 true false 68 107 75 218
Polygon -13345367 true false 65 106 13 136 65 159 65 106
Circle -16777216 true false 221 45 46
Circle -955883 true false 195 68 46
Circle -955883 true false 223 47 42

brush-type-icon-nest2
false
0
Rectangle -6459832 true false 0 0 300 300
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255
Rectangle -16777216 false false 0 0 302 301
Circle -16777216 true false 190 28 66
Circle -16777216 true false 148 91 52
Circle -16777216 true false 172 65 50
Circle -13791810 true false 174 67 46
Circle -13791810 true false 193 31 60
Circle -13791810 true false 150 93 48
Circle -7500403 true true 37 145 128
Line -13791810 false 174 138 172 176
Line -13791810 false 154 121 110 128
Line -16777216 false 173 180 176 140
Line -16777216 false 172 182 172 142
Line -16777216 false 108 129 151 124
Line -16777216 false 107 128 149 120
Circle -6459832 true false 44 152 114
Circle -16777216 true false 52 161 98

brush-type-icon-trail
false
6
Rectangle -7500403 true false 0 0 300 300
Circle -13840069 true true 58 58 62
Circle -13840069 true true 88 88 62
Circle -13840069 true true 108 108 85
Line -13840069 true 60 75 15 75
Line -13840069 true 75 75 60 15
Line -2674135 false 180 180 195 240
Line -2674135 false 195 240 240 180
Line -2674135 false 240 180 270 270
Polygon -2674135 true false 270 270 255 255 270 240 270 270
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-trail2
false
6
Rectangle -7500403 true false 0 0 300 300
Circle -13840069 true true 58 58 62
Circle -13840069 true true 88 88 62
Circle -13840069 true true 108 108 85
Line -13840069 true 60 75 15 75
Line -13840069 true 75 75 60 15
Line -2674135 false 180 180 195 240
Line -2674135 false 195 240 240 180
Line -2674135 false 240 180 270 270
Polygon -2674135 true false 270 270 255 255 270 240 270 270
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 270 270 240 240 270 225 270 270

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bug new
true
0
Circle -7500403 true true 105 165 90
Circle -7500403 true true 118 118 62
Circle -7500403 true true 118 73 62
Line -7500403 true 135 90 105 45
Line -7500403 true 195 45 165 90

bug new 2
true
0
Circle -7500403 true true 105 165 90
Circle -7500403 true true 118 118 62
Circle -7500403 true true 118 73 62

bug new 3
true
0
Circle -7500403 true true 105 165 90
Circle -7500403 true true 118 118 62

bug2
true
0
Circle -16777216 true false 105 75 88
Circle -16777216 true false 105 120 90
Circle -16777216 true false 90 180 120
Line -16777216 false 75 30 180 120
Line -16777216 false 75 30 180 135
Line -16777216 false 225 30 120 120
Line -16777216 false 225 30 120 135
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 75 30
Line -7500403 true 150 100 225 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle outline
true
0
Circle -7500403 false true 0 0 300

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

empty
false
0

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pen
false
6
Polygon -1184463 true false 75 105 225 255 240 255 255 240 255 225 105 75 90 105
Polygon -16777216 false false 75 105 90 105 105 90 105 75 255 225 255 240 105 90 90 105 240 255 255 240 240 255 225 255 75 105
Polygon -2674135 true false 105 75 60 60 75 105 90 105 105 90 105 75

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

polygon full
false
0
Polygon -7500403 true true 0 0 300 0 300 300 0 300 0 0

rectangle
false
0
Rectangle -7500403 true true 0 105 300 195

seed
false
0
Circle -7500403 true true 95 75 110
Circle -7500403 true true 72 104 156
Polygon -7500403 true true 221 149 195 101 106 99 80 148
Polygon -7500403 true true 195 105 180 75 165 60 135 60 120 75 105 105 180 90
Circle -7500403 true true 135 45 30

seed-outline
true
0
Circle -16777216 true false 95 75 110
Circle -16777216 true false 72 104 156
Polygon -16777216 true false 221 149 195 101 106 99 80 148
Polygon -16777216 true false 195 105 180 75 165 60 135 60 120 75 105 105 180 90
Circle -16777216 true false 135 45 30
Circle -7500403 true true 90 135 120
Polygon -7500403 true true 120 240 90 210 90 195 90 180 90 150 105 120 120 90 135 75 150 60 165 75 180 90 195 120 210 150 210 165 210 195 210 210 180 240
Polygon -7500403 true true 120 240
Circle -7500403 true true 90 120 120

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

square full
false
0
Rectangle -7500403 true true 0 0 300 300

square outline
false
0
Rectangle -7500403 false true 0 0 300 300

square outline thick
false
0
Rectangle -7500403 true true 0 285 300 300
Rectangle -7500403 true true 285 0 300 300
Rectangle -7500403 true true 0 0 300 15
Rectangle -7500403 true true 0 0 15 300

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile brick 2
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 0 0 90 120
Rectangle -7500403 true true 120 0 300 120
Rectangle -7500403 true true 0 150 180 270
Rectangle -7500403 true true 210 150 300 270

tile brick 3
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 0 0 75 105
Rectangle -7500403 true true 120 0 300 105
Rectangle -7500403 true true 0 150 180 255
Rectangle -7500403 true true 225 150 300 255

tile brick 4
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 0 0 75 105
Rectangle -7500403 true true 135 0 315 105
Rectangle -7500403 true true 0 150 165 255
Rectangle -7500403 true true 225 150 300 255

tile log
false
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 30 45 15
Line -16777216 false 45 15 120 30
Line -16777216 false 120 30 180 45
Line -16777216 false 180 45 225 45
Line -16777216 false 225 45 165 60
Line -16777216 false 165 60 120 75
Line -16777216 false 120 75 30 60
Line -16777216 false 30 60 0 60
Line -16777216 false 300 30 270 45
Line -16777216 false 270 45 255 60
Line -16777216 false 255 60 300 60
Polygon -16777216 false false 15 120 90 90 136 95 210 75 270 90 300 120 270 150 195 165 150 150 60 150 30 135
Polygon -16777216 false false 63 134 166 135 230 142 270 120 210 105 116 120 88 122
Polygon -16777216 false false 22 45 84 53 144 49 50 31
Line -16777216 false 0 180 15 180
Line -16777216 false 15 180 105 195
Line -16777216 false 105 195 180 195
Line -16777216 false 225 210 165 225
Line -16777216 false 165 225 60 225
Line -16777216 false 60 225 0 210
Line -16777216 false 300 180 264 191
Line -16777216 false 255 225 300 210
Line -16777216 false 16 196 116 211
Line -16777216 false 180 300 105 285
Line -16777216 false 135 255 240 240
Line -16777216 false 240 240 300 255
Line -16777216 false 135 255 105 285
Line -16777216 false 180 0 240 15
Line -16777216 false 240 15 300 0
Line -16777216 false 0 300 45 285
Line -16777216 false 45 285 45 270
Line -16777216 false 45 270 0 255
Polygon -16777216 false false 150 270 225 300 300 285 228 264
Line -16777216 false 223 209 255 225
Line -16777216 false 179 196 227 183
Line -16777216 false 228 183 266 192

tile stones
false
0
Rectangle -6459832 true false 0 0 300 300
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
