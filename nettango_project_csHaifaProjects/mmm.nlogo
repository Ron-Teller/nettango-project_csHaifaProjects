extensions [send-to fetch import-a]
;extensions [send-to fetch import-a profiler]

globals [
  tick-count ;; count how many turns this model has executed ("go" procedure invoked)
  current-population-properties-are-being-set-for-in-nettango ;; keeps track of which population we are setting properties for in nettango
  ball-population-properties ;; list that holds properties for each population. Each index is a different property. Check report procedure "property-index"
  population-to-set-properties-for-in-ui ;; which population is selected in the ball pallet in ui
  default-colors-for-ball-populations
  counters-information-gfx-overlay ;; breed that references 2 gfx-overlay turtles that display information for counter
  ball-count-in-counters ;; list that keeps track of ball count in all counters
  time-when-brush-buttons-were-first-clicked ;; used for radio buttons for brush. keeps track of what order brush buttons were clicked so the right button is unpressed
  current-background-color ;; gets updated when user clicks "paint-world" button
  brush-radio-button-counter ;; increased when one of the brush buttons is clicked, used to keep track of which button was pressed last
  nettango-what-ball-meets-in-if-ball-meets-block ;; used to keep track for which entity (ball meets) the interaction block is defined for
  wall-collision-count ;; list of wall collisions for each population.
  log-history ;; keeps track of all log history. need this because netlogo web can not append to a file, so need to write whole log every time
  log-picture-count ;; keeps track how many pictures logged so far so the file can be named with picture number in ascending order

  gravity-acceleration-x   ;; acceleration of field (gravity, electric)
  gravity-acceleration-y   ;; acceleration of field (gravity, electric)
  ;heading-acceleration     ;; direction of field
  ;avg-speed-init avg-energy-init      ;; initial averages
  ;avg-speed avg-energy                ;; current averages
  ;particle-mass
  tick-advance-amount                 ;; the amount by which we will advance ticks
  ;temperature
  ;volume
  ;pressure
  ;outside-energy
  ;lost-balls                     ;; particles that have escaped the pull of gravity (reached the top of the World & View)
                                      ;; these particles are removed from the simulation
  ;percent-lost-balls
  ;max-tick-advance-amount             ;; the largest a tick length is allowed to be
  maxballs                       ;; possibly omit later, to prevent balls slowing down too much so that it's visible and confuses the students about speed
  ;total-balls1-number   total-balls2-number
  ;box-x box-y                ;; patch coords of box's upper right corner
  ;box-center-x   box-center-y ;;patch coords of box's center
  ;circle-radius  ;; radius of circle to be drawn
  ;patch-colors-saved-FLAG  ;; flag to save the colors of the patch
  ;first-click-FLAG  ;;; for drawing rectange and circles
  ;obstacles
  deltaSpeed    ;  value to increase or decrease speed
  max-speed     ; max allowed speed in system (recursive speed increase may blow up the variable)
  ;last-mouse-click-xcor
  ;last-mouse-click-ycor
  lookAhead  ; distance to check ahead if near wall
  ;avg-speed-population1 avg-energy-population1
  ;avg-speed-population2 avg-energy-population2
  ;world-color
  ;wall-color
  field-color
  field-count ; counts the number of different fields (was "clusters")
  ;field-width
;  max-field-spread
;  counter-color
  counter-width
  counter-count  ; will hold the number of the counter
  ;counter-time-window ; number of time units over which to sum balls on counter
  ;counter-delta-time  ; will count the time units
;  flash-color    ; color of flash
  flash-time     ; length of time of flash
;  starter
;  fixPrevFieldPatch  ; flag to determine if prev mouse position needs to be added to field
  eps-collision  ; how deep the intersection of balls can be to be considered collision

  log-filename  ; will hold filename
  log-filename-photo ; will hold photo file name
  prev-command-name ; will hold the prev command printedin log file (to avoid double logging)
  prev-line  ; will hold the last line printedin log file
  repulsion-strength
  attraction-strength
  LJeps   ; Lennard Jones constants
  LJsigma ; Lennard Jones constants

;======= BRUSH VARIABLES ===========
  brush-shape                           ;; square or circle
  brush-type                            ;; what is brush drawing?
  center-patch-of-drawn-shape           ;; keeps track of patch brush first clicked on when shape was first drawn.
  patches-affected-by-drawn-shape       ;; patches that would be drawn on if user were to draw shape right now
  gfx-displaying-patches-affected-by-drawn-shape    ;; turtles that only serve to display boundaries of shape currently being configured
  mouse-xy-when-brush-was-pressed-down  ;; x,y coordinates when brush was first clicked
  shape-drawn-by-brush                  ;; circle,rectangle,line,square
  -brush-border-outline                 ;; gfx turtle displaying which patches will get drawn onby brush
  -brush-cursor                         ;; gfx turtle displaying brush cursor
  brush-style                           ;; is brush drawing free-form or a shape
  brush-type-icon                       ;; icon top right of model displaying what brush is drawing
  brush-draw-erase-mode-icon            ;; icon top right of model displaying if brush is set to draw, erase, or configuring shape
  brush-icon-size
  brush-icon-transparency-normalized
  brush-in-draw-mode                    ;; true if brush is drawing, false if erasing
  mouse-down?-when-brush-was-last-activated
  mousexy-when-brush-was-last-activated
  current-mousexy
  current-mouse-down?
  current-mouse-inside?
  patches-drawn-on-since-brush-was-held-down    ;; keeps track if you do not want to draw twice on the same patch since brush was pressed down.
  counter-number-drawn-by-brush                 ;; counter number currently being drawn by brush
  first-patch-brush-configured-field-on
  brush-activated-after-model-was-advanced      ;; to know if display should be updated because model isnt running which means display isn't updated in "go" procedure
]

; order of breeds determines layering of turtles. (Later defined is on top)
breed [ counter-information-gfx a-counter-information-gfx]
breed [ batteries battery ]
breed [ counters counter]
breed [ flashes flash ]      ;; a gfx breed only used to animate a flash
breed [ arrows arrow]
breed [ halos halo]
breed [ balls ball]
breed [ erasers eraser ]
breed [gfx-overlay a-gfx-overlay] ;; gfx breed
breed [brush-border-outlines brush-border-outline]
breed [brush-cursors brush-cursor]

counter-information-gfx-own [
  counter-number-gfx-overlay ;; empty turtle that only displays its label as counter number
  ball-count-gfx-overlay ;; empty turtle that only displays its label as counter ball count
]

flashes-own [birthday]       ;; flashes only last for a short period and then disappear.
                             ;; their birthday helps us keep track of when they were created and
                             ;; when we need to remove them.
balls-own
[
  ;table
  population-num             ;; Which population the ball belongs to
;  leader                     ;; for stick togather slider
  speed mass energy          ;; particle info
;  wall-hits                  ;; # of wall hits during this clock cycle
;  momentum-difference        ;; used to calculate pressure from wall hits
;  momentum-instant           ;; used to calculate pressure
  last-collision             ;; keeps track of last particle this particle collided with
;  stuck-on-wall?             ;; pays attention if the balls is stuck to exclude him from movement
;  turn-amount                         ;; This is used to make all of the nodes in a cluster turn by
                                      ;; the same number of degrees.  Each leader chooses a random
                                      ;; amount, then everyone else uses the amount from their leader.
;  stick-to-wall?
  on-counter
  tick-count-move-enabled     ;; tick count when move was enabled to move if in blocks set to "Move X Steps"
;  my-field-x                 ;;  local field working on ball
;  my-field-y                 ;;  local field working on ball
]

erasers-own [ pressure? ]    ;; new

patches-own
[
  population-field-x  ;;  list of vectors field_x and field_y define the distinct direction and strength of the electric field for each population
  population-field-y  ;;  list of vectors field_x and field_y define the distinct direction and strength of the electric field for each population
  field-x             ;;  vector  field_x and field_y define the direction and strength of the electric field within the patch
  field-y             ;;  vector  field_x and field_y define the direction and strength of the electric field within the patch
  accum-x             ;;  accumulates vector  field_x for gobal field computation
  accum-y             ;;  accumulates vector  field_y for gobal field computation
  accum-w             ;;  accumulates weights  for gobal field computation
;  hold-color          ;; temporarily holds patch color while painting boxes or circles
  field-number        ;; holds the component number of the field (was "cluster")
;  cluster             ;; GIGI  - DO WE NEED THIS NOW? holds the label (patch) of the electric component. we need this to ensure balls leaveand return to same component/cluster  ALSO used for counter numbering
;  cluster-number      ;; holds the label (number) of the electric component. we need this to ensure balls leaveand return to same component/cluster  ALSO used for counter numbering
 ; pcounter            ;; used when patch is a counter
  isPainted           ;; is true on patches that were drawn with draw-field
  has-wall            ;; true if patch has wall
]

counters-own
[
;  counter-head        ;; holds the label of the counter component which will display th ecounts in this counter.
  counter-number      ;; holds the counter number
;  ball-count          ;; used when patch is a counter
]

to initialize-properties-for-first-n-ball-populations [amount]
  foreach (range 1 (amount + 1)) [population -> initialize-properties-for-ball-population-if-they-have-not-been-set population]
end

to crt-pop
  ; for use only in desktop version, since we dont have blocks to define population properties.
  initialize-properties-for-first-n-ball-populations 2
  set-property-for-population 1 "initial-size" 0.5
  set-property-for-population 1 "if-ball-meets-wall-heading" "bounce"
  set-property-for-population 1 "if-ball-meets-wall-speed" "bounce"
  set-property-for-population 1 "if-ball-meets-ball-heading" "collide" set-property-for-population 1 "if-ball-meets-ball-speed" "collide"
  ;set-property-for-population 1 "if-ball-meets-ball-heading" "repel and attract" set-property-for-population 1 "if-ball-meets-ball-speed" "repel and attract"
  ;set-property-for-population 1 "if-ball-meets-ball-heading" "attract" set-property-for-population 1 "if-ball-meets-ball-speed" "attract"
  ;set-property-for-population 1 "if-ball-meets-ball-heading" "repel" set-property-for-population 1 "if-ball-meets-ball-speed" "repel"
  set-property-for-population 1 "if-ball-meets-ball-other-population-heading" "collide"
  set-property-for-population 1 "if-ball-meets-ball-other-population-speed" "collide"
  set-property-for-population 1 "gravity" 0
  set-property-for-population 1 "electric-field" 100
  set-property-for-population 2 "if-ball-meets-wall-heading" "bounce"
  set-property-for-population 2 "if-ball-meets-wall-speed" "bounce"
  set-property-for-population 2 "if-ball-meets-ball-heading" "collide" set-property-for-population 2 "if-ball-meets-ball-speed" "collide"
  ;set-property-for-population 2 "if-ball-meets-ball-heading" "repel and attract" set-property-for-population 2 "if-ball-meets-ball-speed" "repel and attract"
  ;set-property-for-population 2 "if-ball-meets-ball-heading" "attract" set-property-for-population 2 "if-ball-meets-ball-speed" "attract"
  ;set-property-for-population 2 "if-ball-meets-ball-heading" "repel" set-property-for-population 2 "if-ball-meets-ball-speed" "repel"
  set-property-for-population 2 "if-ball-meets-ball-other-population-heading" "collide"
  set-property-for-population 2 "if-ball-meets-ball-other-population-speed" "collide"
  set-property-for-population 2 "gravity" 0
  set-property-for-population 2 "electric-field" 0
end

to set-global-values
  set tick-count 0
  ;set ball-population-properties table-make
  set ball-population-properties []
  set population-to-set-properties-for-in-ui "-"
  set default-colors-for-ball-populations [red blue lime orange violet yellow cyan pink brown green sky magenta turquoise gray ]
  set counters-information-gfx-overlay []
  set first-patch-brush-configured-field-on nobody
  set ball-count-in-counters []
  set brush-activated-after-model-was-advanced false
  set time-when-brush-buttons-were-first-clicked table-make
  ;set time-when-brush-buttons-were-first-clicked table:make
  set current-background-color background-color
  set brush-radio-button-counter 0
  set log-history ""
  set log-picture-count 0
  set wall-collision-count [0 0]

  set maxballs 2000
  set deltaSpeed 0.5;
  set max-speed 10
  set lookAhead 0.6
  ;set world-color black
  ;set wall-color blue
  set field-color 87
  set field-count 0
  ;set max-field-spread 20 ; spread the field only within a radius  (max world is -26 <->  +26
  set counter-width 1.25
  ;set counter-color Gray
  set counter-count 1.5 ;refactor change back to 0
;  set counter-time-window 1000
;  set counter-delta-time 0
;  set flash-color wall-color + 2
  set flash-time  15
  set-default-shape flashes "square"
  set repulsion-strength 100
  set attraction-strength 30
  set gravity-acceleration-x 0
  set gravity-acceleration-y -9.8
  set eps-collision 0.99
  set tick-advance-amount 1 / 50   ; MAXIMUM possible value of ball speed. Change this if changed SLIDER in interface
  setup-logging  "LOGGING/logFile"  ; sets the log file name log-filename
  ;setup-logging  "logFile"  ; sets the log file name log-filename
  set prev-command-name "None"
  set prev-line "None"
  set LJeps 0.5  ; Lennard Jones constants
;  set LJsigma balls-Size; Lennard Jones constants
  set-default-shape halos "thin ring"
  ;set patch-colors-saved-FLAG FALSE
  ;set first-click-FLAG TRUE
  ask patches [
    set has-wall false
    set population-field-x []
    set population-field-y []
    ;set population-field-x table:make
    ;set population-field-y table:make
    ;set population-field-x table-make
    ;set population-field-y table-make
  ]
end

to update-display-every [seconds]
  every seconds [display]
end

to iterate-through-population-number-in-ui-by-ascending-circular-order
  let -population-numbers population-numbers
  ifelse is-a-population-selected-in-ui [
    let index-of-current-populaiton-in-ui position population-to-set-properties-for-in-ui -population-numbers
    set population-to-set-properties-for-in-ui
          item ((index-of-current-populaiton-in-ui + 1) mod (length -population-numbers)) -population-numbers ]
  [
    set population-to-set-properties-for-in-ui min -population-numbers
  ]
end

to-report population-numbers
  ;report table-all-keys ball-population-properties
  ;report table:keys ball-population-properties
  report filter [population -> population-properties-initialized? population] n-values (length ball-population-properties) [i -> i + 1]
end

to-report any-population-exists
  report length population-numbers > 0
end

to select-next-population-in-properties-ui
  if any-population-exists [
    iterate-through-population-number-in-ui-by-ascending-circular-order
    ;update-properties-in-ui-for-current-population
  ]
end

to-report highest-population-number
  report max population-numbers
end

to-report unused-population-number-higher-than-existing-population-numbers
  ifelse any-population-exists [
    report highest-population-number + 1]
  [
    report 1
  ]
end

to set-new-population-to-set-properties-for-in-ui
  set population-to-set-properties-for-in-ui unused-population-number-higher-than-existing-population-numbers
end

to-report default-color-for-population [population-number]
  let population-colors map [population -> get-ball-population-property population "initial-color"] population-numbers
  let default-colors-not-used-by-any-population filter [default-color -> not member? default-color population-colors] default-colors-for-ball-populations
  ifelse not empty? default-colors-not-used-by-any-population [
    report first default-colors-not-used-by-any-population ]
  [
    report item (population-number mod length default-colors-not-used-by-any-population) default-colors-not-used-by-any-population
  ]
end

to-report is-a-population-selected-in-ui
  report is-number? population-to-set-properties-for-in-ui
end

to-report is-first-time-radio-button-is-pressed-down [button]
  report not table-has-key? time-when-brush-buttons-were-first-clicked button
  ;report not table:has-key? time-when-brush-buttons-were-first-clicked button
end

to update-record-of-when-brush-radio-button-was-first-clicked [button]
  ifelse is-first-time-radio-button-is-pressed-down button [
    set brush-radio-button-counter brush-radio-button-counter + 1
    set time-when-brush-buttons-were-first-clicked table-put time-when-brush-buttons-were-first-clicked button brush-radio-button-counter ]
    ;table:put time-when-brush-buttons-were-first-clicked button brush-radio-button-counter ]
  [
    let first-time-button-was-pressed table-get time-when-brush-buttons-were-first-clicked button
    foreach (filter [key -> (key != button) and (table-get time-when-brush-buttons-were-first-clicked key < first-time-button-was-pressed)] table-all-keys time-when-brush-buttons-were-first-clicked )
      [key -> set time-when-brush-buttons-were-first-clicked table-remove time-when-brush-buttons-were-first-clicked key]
    ;let first-time-button-was-pressed table:get time-when-brush-buttons-were-first-clicked button
    ;foreach (filter [key -> (key != button) and (table:get time-when-brush-buttons-were-first-clicked key < first-time-button-was-pressed)] table:keys time-when-brush-buttons-were-first-clicked )
    ;  [key -> table:remove time-when-brush-buttons-were-first-clicked key]
  ]
end

to-report should-release-brush-radio-button? [button]
  ;should be called from a procedure ran by a brush button in tht interface, only once per button name
  unselect-brush-radio-button-if-another-button-was-clicked-more-recently button
  report not table-has-key? time-when-brush-buttons-were-first-clicked button
  ;report not table:has-key? time-when-brush-buttons-were-first-clicked button
end

to unselect-brush-radio-button-if-another-button-was-clicked-more-recently [button]
  update-record-of-when-brush-radio-button-was-first-clicked button
  if another-brush-radio-button-was-clicked-more-recently button [
    deselect-brush-radio-button button ]
end

to-report another-brush-radio-button-was-clicked-more-recently [button]
  let first-time-button-was-pressed table-get time-when-brush-buttons-were-first-clicked button
  let buttons-pressed-more-recently filter [key -> (key != button) and (table-get time-when-brush-buttons-were-first-clicked key > first-time-button-was-pressed)]
    (table-all-keys time-when-brush-buttons-were-first-clicked)
  ;let first-time-button-was-pressed table:get time-when-brush-buttons-were-first-clicked button
  ;let buttons-pressed-more-recently filter [key -> (key != button) and (table:get time-when-brush-buttons-were-first-clicked key > first-time-button-was-pressed)]
  ;  (table:keys time-when-brush-buttons-were-first-clicked)
  report not empty? buttons-pressed-more-recently
end

to deselect-brush-radio-button [button]
  set time-when-brush-buttons-were-first-clicked table-remove time-when-brush-buttons-were-first-clicked button
  ;table:remove time-when-brush-buttons-were-first-clicked button
end

;==============================================================
; these procedures implement a hash map that replaces the extension "table" temporarily because a bug in netlogo web
; makes it unusable.
; 23/9/2020 Update: NetTango devops team updated that bug was fixed and should soon be pushed to production server.
; When that happens these functions can be erased and instead use the table extension. The code using this extension is
; already implemented but commented out. After erasing these functions, simply keep compiling the model and it will
; jump to lines of code that use these functions. Above them is the equivilent line of code that only uses the table extension,
; so uncomment them and erase the lines of code using these procedures below.

to-report table-make
  report []
end

to-report table-from-list [-list]
  report -list
end

to-report table-has-key? [-table key]
  report key-index -table key != false
end

to-report table-put [-table key value]
  let -key-index key-index -table key
  let key-already-exists -key-index != false
  ifelse key-already-exists [
    report replace-item -key-index -table (list key value)
  ] [
    report lput (list key value) -table
  ]
end

to-report table-get [-table key]
  report item 1 (item (key-index -table key) -table)
end

to-report table-remove [-table key]
  let key-exists key-index -table key != false
  ifelse key-exists [
    report remove-item (key-index -table key) -table ]
  [
    report -table
  ]
end

to-report key-index [-table key]
  let index false
  let i 0
  while [i < length -table] [
    if (item 0 (item i -table)) = key [
      set index i
      set i length -table ;exit while loop
    ]
    set i i + 1
  ]
  report index
end

to-report table-all-keys [-table]
  report map [key-value-pair -> item 0 key-value-pair] -table
end

;======================== end of alternative "table" extension procedures ======

to #nettango#set-current-population-of-properties-being-set [population]
  ;maybe change name to set-population-that-properties-are-being-set-for-in-nettango
  set current-population-properties-are-being-set-for-in-nettango population
  initialize-properties-for-ball-population-if-they-have-not-been-set population
end

to-report population-properties-initialized? [population]
  ;report length (item (population - 1) ball-population-properties) > 0
  report ifelse-value population > length ball-population-properties [false] [length (item (population - 1) ball-population-properties) > 0]
end

to initialize-properties-for-ball-population-if-they-have-not-been-set [population]
  ;if not table-has-key? ball-population-properties population [

  ;if not table:has-key? ball-population-properties population [
  ;  initialize-ball-population-properties population
  ;]

  if not population-properties-initialized? population [
     initialize-ball-population-properties population
  ]
end

to initialize-ball-population-properties [population]
  if population > length ball-population-properties [
    foreach (range length ball-population-properties population 1) [
      index -> set ball-population-properties insert-item index ball-population-properties []
        ask patches [
          set population-field-x insert-item index population-field-x 0
          set population-field-y insert-item index population-field-y 0
        ]
    ]
  ]
  let population-color default-color-for-population population
  ;set ball-population-properties table-put ball-population-properties population initialized-population-properties
  ;table:put ball-population-properties population initialized-population-properties
  set ball-population-properties replace-item (population - 1) ball-population-properties initialized-population-properties2
  set-initial-color-for-population population population-color
end

to-report initialized-population-properties2
  report (list
    0.5
    "random"
    10
    gray
    true
    "no change"
    "no change"
    "no change"
    "no change"
    "no change"
    "no change"
    0
    0)
end

;to-report initialized-population-properties
;  ;report table-from-list [
;  report table:from-list [
;    ["initial-size" 0.5]
;    ["initial-heading" "random"]
;    ["initial-speed" 10]
;    ["initial-color" gray]
;    ["move-forward" true]
;    ["if-ball-meets-wall-heading" "no change"]
;    ["if-ball-meets-wall-speed" "no change"]
;    ["if-ball-meets-ball-heading" "no change"]
;    ["if-ball-meets-ball-speed" "no change"]
;    ["if-ball-meets-ball-other-population-heading" "no change"]
;    ["if-ball-meets-ball-other-population-speed" "no change"]
;    ["gravity" 0]
;    ["electric-field" 0]
;  ]
;end

to-report amount-of-balls-that-can-be-created-given-maximum-capacity [requested-amount]
  let maximum-amount-of-balls-that-can-currently-be-created (maxballs - count balls)
  report ifelse-value requested-amount > maximum-amount-of-balls-that-can-currently-be-created [maximum-amount-of-balls-that-can-currently-be-created] [requested-amount]
end

to notify-user-unable-to-create-balls-due-to-maximum-capacity
  user-message (word "Unable to create more balls, maximum capacity of " maxballs " reached.")
end

to create-balls-if-under-maximum-capacity [population amount -xcor -ycor]
  let amount-of-balls-to-create amount-of-balls-that-can-be-created-given-maximum-capacity amount
  let unable-to-create-balls-due-to-maximum-capacity ifelse-value (amount-of-balls-to-create = 0) and (amount > 0) [true] [false]
  ifelse unable-to-create-balls-due-to-maximum-capacity [
    notify-user-unable-to-create-balls-due-to-maximum-capacity]
  [
    create-balls-at population amount-of-balls-to-create -xcor -ycor
  ]
end

to create-balls-at [population amount -xcor -ycor]
  create-balls amount [
    set population-num population
    set shape  "circle"
    set color initial-color
    set size initial-size
    set tick-count-move-enabled tick-count
    set speed initial-speed
    set mass initial-size
   ; set heading 1000    ;; temp value to change below so that only THESE new balls will get new value
    ;set leader self
    set last-collision nobody
    ;set stuck-on-wall? false
    ;set wall-hits 0
    ;set momentum-difference 0
    setxy -xcor -ycor
    ;; if we're only placing -one particle, use the exact position
    ifelse amount > 1 [ jump random-float 3 ] [jump random-float 0.01]
    initialize-ball-heading
]
  if (prev-command-name != "place-balls") [
         log-output "place-balls"
  ]
end

; ball procedure
to initialize-ball-heading
  ifelse initial-heading = "random" [
    set heading random-float 360 ]
  [
    set heading [initial-heading] of self
  ]
end

to-report get-ball-population-property [population property]
  ;report table-get (get-ball-population-properties population) property
  ;report table:get (get-ball-population-properties population) property
  ( ifelse
    property = "initial-size" [report item 0 (item (population - 1) ball-population-properties)]
    property = "initial-heading" [report item 1 (item (population - 1) ball-population-properties)]
    property = "initial-speed" [report item 2 (item (population - 1) ball-population-properties)]
    property = "initial-color" [report item 3 (item (population - 1) ball-population-properties)]
    property = "move-forward" [report item 4 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-wall-heading" [report item 5 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-wall-speed" [report item 6 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-ball-heading" [report item 7 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-ball-speed" [report item 8 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-ball-other-population-heading" [report item 9 (item (population - 1) ball-population-properties)]
    property = "if-ball-meets-ball-other-population-speed" [report item 10 (item (population - 1) ball-population-properties)]
    property = "gravity" [report item 11 (item (population - 1) ball-population-properties)]
    property = "electric-field" [report item 12 (item (population - 1) ball-population-properties)]
  )
end

to-report population-repels-or-attracts-other-populations? [population]
  let interaction item 9 (item (population - 1) ball-population-properties)
  report interaction = "repel" or interaction = "attract" or interaction = "repel and attract"
end

;========== getters and setters for ball properties ========

;ball procedure
to-report get-ball-property [property]
  report get-ball-population-property population-num property
end

; ball procedure
to-report initial-heading
  ;report get-ball-property "initial-heading"
  report item 1 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report initial-speed
  ;report get-ball-property "initial-speed"
  report item 2 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report initial-color
  ;report get-ball-property "initial-color"
  report item 3 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report initial-size
  ;report get-ball-property "initial-size"
  report item 0 (item (population-num - 1) ball-population-properties)
end

;ball procedure
to-report move-forward
  ;report get-ball-property "move-forward"
  report item 4 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report wall-collision-heading-change
  ;report get-ball-property "if-ball-meets-wall-heading"
  report item 5 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report wall-collision-speed-change
  ;report get-ball-property "if-ball-meets-wall-speed"
  report item 6 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report ball-collision-heading-change
  ;report get-ball-property "if-ball-meets-ball-heading"
  report item 7 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report ball-collision-speed-change
  ;report get-ball-property "if-ball-meets-ball-speed"
  report item 8 (item (population-num - 1) ball-population-properties)
end

; ball procedure
to-report is-affected-by-gravity
  ;report get-ball-property "gravity" > 0
  report ball-gravity-acceleration != 0
end

;ball procedure
to-report ball-collision-different-populations-heading-change
  ;report global-ball-collide-heading
  ;report get-ball-property "if-ball-meets-ball-other-population-heading"
  report item 9 (item (population-num - 1) ball-population-properties)
end

;ball procedure
to-report ball-collision-different-populations-speed-change
  ;report global-ball-collide-speed
  ;report get-ball-property "if-ball-meets-ball-other-population-speed"
  report item 10 (item (population-num - 1) ball-population-properties)
end

;ball procedure
to-report ball-gravity-acceleration
  ;report get-ball-property "gravity"
  report item 11 (item (population-num - 1) ball-population-properties)
end

;ball procedure
to-report ball-electric-field
  ;report get-ball-property "electric-field"
  report item 12 (item (population-num - 1) ball-population-properties)
end

to #nettango#setup-if-ball-meets-block
end
to #nettango#teardown-if-ball-meets-block
end

to #nettango#set-if-ball-meets-block-what-ball-meets [what-ball-meets]
  set nettango-what-ball-meets-in-if-ball-meets-block what-ball-meets
end

to-report what-ball-meets-in-nettango-block
  report nettango-what-ball-meets-in-if-ball-meets-block
end

to #nettango#set-heading-change [heading-change]
  let what-ball-meets what-ball-meets-in-nettango-block
  let population current-population-properties-are-being-set-for-in-nettango
  (ifelse
    what-ball-meets = "wall" [
      set heading-change ifelse-value heading-change = "collide" ["bounce"] [heading-change]
      set-if-ball-meets-wall-heading-for-population population heading-change ]
    what-ball-meets = "ball-same-population" [
      set-if-ball-meets-ball-heading-for-population population heading-change ]
    what-ball-meets = "ball-other-population" [
        set-if-ball-meets-ball-other-population-heading-for-population population heading-change] )
end

to #nettango#set-speed-change [speed-change]
  let what-ball-meets what-ball-meets-in-nettango-block
  let population current-population-properties-are-being-set-for-in-nettango
  ifelse what-ball-meets = "wall" [
    set speed-change ifelse-value speed-change = "collide" ["bounce"] [speed-change]
    set-if-ball-meets-wall-speed-for-population population speed-change
  ]
  [
    ifelse what-ball-meets = "ball-same-population" [
      set-if-ball-meets-ball-speed-for-population population speed-change
    ]
    [
      if what-ball-meets = "ball-other-population" [
        set-if-ball-meets-ball-other-population-speed-for-population population speed-change
      ]
    ]
  ]
end

to #nettango#set-field [strength]
  let population current-population-properties-are-being-set-for-in-nettango
  (ifelse
    what-ball-meets-in-nettango-block = "gravity-field" [set-gravity-property-for-population population strength]
    what-ball-meets-in-nettango-block = "electric-field" [set-property-for-population population "electric-field" strength]
  )
end

to-report get-ball-population-properties [population]
  ;report table-get ball-population-properties population
  ;report table:get ball-population-properties population
  report item (population - 1) ball-population-properties
end

to set-property-for-population [population property value]
  ;table:put (get-ball-population-properties population) property value

  ;set ball-population-properties table-put ball-population-properties  population
  ;      (table-put (get-ball-population-properties population) property value)

  set ball-population-properties replace-item (population - 1) ball-population-properties (replace-item (property-index property) (item (population - 1) ball-population-properties) value)
end

to-report property-index [property]
  let index 0
  (ifelse
    property = "initial-size" [set index 0]
    property = "initial-heading" [set index 1]
    property = "initial-speed" [set index 2]
    property = "initial-color" [set index 3]
    property = "move-forward" [set index 4]
    property = "if-ball-meets-wall-heading" [set index 5]
    property = "if-ball-meets-wall-speed" [set index 6]
    property = "if-ball-meets-ball-heading" [set index 7]
    property = "if-ball-meets-ball-speed" [set index 8]
    property = "if-ball-meets-ball-other-population-heading" [set index 9]
    property = "if-ball-meets-ball-other-population-speed" [set index 10]
    property = "gravity" [set index 11]
    property = "electric-field" [set index 12]
  )
  report index
end

to set-initial-speed-for-population [population -speed]
  set-property-for-population population "initial-speed" -speed
end

to set-initial-size-for-population [population -size]
  set-property-for-population population "initial-size" -size
end

to set-initial-color-for-population [population -color]
  set-property-for-population population "initial-color" -color
end

to set-initial-heading-for-population [population -heading]
  set-property-for-population population "initial-heading" -heading
end

to set-if-ball-meets-wall-heading-for-population [population -heading]
  set-property-for-population population "if-ball-meets-wall-heading" -heading
end

to set-if-ball-meets-wall-speed-for-population [population -speed]
  set-property-for-population population "if-ball-meets-wall-speed" -speed
end

to set-if-ball-meets-ball-heading-for-population [population -heading]
  set-property-for-population population "if-ball-meets-ball-heading" -heading
end

to set-if-ball-meets-ball-speed-for-population [population -speed]
  set-property-for-population population "if-ball-meets-ball-speed" -speed
end

to set-ball-forward-property-for-population [population -move-forward]
  set-property-for-population population "move-forward" -move-forward
end

to set-if-ball-meets-ball-other-population-heading-for-population [population -heading]
  set-property-for-population population "if-ball-meets-ball-other-population-heading" -heading
end

to set-if-ball-meets-ball-other-population-speed-for-population [population -speed]
  set-property-for-population population "if-ball-meets-ball-other-population-speed" -speed
end

to set-gravity-property-for-population [population strength]
  set-property-for-population population "gravity" strength
end

to set-electric-field-property-for-population [population strength]
  if strength != get-ball-population-property population "electric-field" [
    set-property-for-population population "electric-field" strength
    recalculate-field-values-for-population population
  ]
end

to #nettango#if-ball-meets-wall [-heading -speed]
  let population current-population-properties-are-being-set-for-in-nettango
  set-if-ball-meets-wall-heading-for-population population -heading
  set-if-ball-meets-wall-speed-for-population population -speed
end

to #nettango#if-ball-meets-ball [-heading -speed]
  let population current-population-properties-are-being-set-for-in-nettango
  set-if-ball-meets-ball-heading-for-population population -heading
  set-if-ball-meets-ball-speed-for-population population -speed
end

to #nettango#move-ball
  let population current-population-properties-are-being-set-for-in-nettango
  let -move-forward true
  set-ball-forward-property-for-population population -move-forward
end

to #nettango#if-ball-meets-electric-field [is-population-affected-by-electric-field]
  let population current-population-properties-are-being-set-for-in-nettango
  set-electric-field-property-for-population population is-population-affected-by-electric-field
end

to #nettango#if-ball-meets-gravity [is-population-affected-by-gravity]
  let population current-population-properties-are-being-set-for-in-nettango
  set-gravity-property-for-population population is-population-affected-by-gravity
end

to paint-arrow [this-patch]
  if ((((round pxcor) mod 2) = 0) and (((round pycor) mod 2) = 0)) [
    sprout-arrows 1
    [
      set shape "arrow"
      set color field-color - 4
      set size 1.0
      set heading atan field-x field-y
     ]
  ]
end

to fill-field
  let current-patch []  ; will hold a patch that is being processed

  let list-patches  sort patches with [field-number = field-count  ]   ; list of patches that were marked
  ; fill patches in connected componnent with field-color
  while [not empty? list-patches]
  [ set current-patch first list-patches
    set list-patches but-first list-patches
    ask current-patch
    ;refactor changed "in-radius-nowrap" to "in-radius"
    ;[    ask patches in-radius-nowrap 1 with [ pcolor != wall-color  and pcolor != field-color ]
    [    ask patches in-radius 1 with [(not has-wall) and (not has-field)]
         [  set pcolor field-color
            set field-number field-count
            set list-patches lput self list-patches  ;add to list-patches  ; Another way set frontier2 (patch-set frontier2 patch-here)
         ] ; end ask neighbors
    ] ; end ask current-patch
  ] ; end field while

  ; now spread the field vectors in all the painted field cells WITHIN connected comp ONLY
  let list-field-patches []
  let marked-patch []  ;first list-field-marked-patches
  let dist 0

  let list-field-marked-patches  patches with [isPainted = TRUE]  ; list of patches that were marked as field by user
  ask  list-field-marked-patches
  [   set marked-patch self
      set list-field-patches  patches with [ field-number = field-count] ; all patches that were colored within same connected comp
      ask list-field-patches
      [
        set dist sqrt ((pxcor - [pxcor] of  marked-patch) ^ 2 + (pycor - [pycor] of  marked-patch) ^ 2 )
;        if dist < max-field-spread  ; spread the field only within a radius
        if (dist = 0) [ set dist (1 / (max-pxcor * 2))]   ; weight is 1/dist and so dist should not be 0
        set accum-w accum-w + (1 / dist)
        set accum-x  accum-x +  ((1 / dist) * [field-x] of marked-patch)
        set accum-y  accum-y +  ((1 / dist) * [field-y] of marked-patch)
;       ] ; end if dist < max-field-spread
    ]
  ]

  ; now compute the final field values of all field patches
  ask list-field-patches
  [  if (accum-w != 0)
     [   set field-x  (accum-x / accum-w)
         set field-y  (accum-y / accum-w)
         ; normalize and set to field strength
         ;set field-x    (field-x / (sqrt ((field-x ^ 2) + (field-y ^ 2)))) * Electric-Field-Strength
         ;set field-y    (field-y / (sqrt ((field-x ^ 2) + (field-y ^ 2)))) * Electric-Field-Strength
         set field-x    (field-x / (sqrt ((field-x ^ 2) + (field-y ^ 2))))
         set field-y    (field-y / (sqrt ((field-x ^ 2) + (field-y ^ 2))))
      ]
  ]

  foreach population-numbers [population -> recalculate-field-values-for-population population]

if (prev-command-name != "fill-field") [
         log-output "fill-field"
    ]
end

to recalculate-field-values-for-population [population]
  ask patches
  [
    set population-field-x replace-item (population - 1) population-field-x (field-x * get-ball-population-property population "electric-field")
    set population-field-y replace-item (population - 1) population-field-y (field-y * get-ball-population-property population "electric-field")
    ;table:put population-field-x population (field-x * get-ball-population-property population "electric-field")
    ;table:put population-field-y population (field-y * get-ball-population-property population "electric-field")
    ;set population-field-x table-put population-field-x population (field-x * get-ball-population-property population "electric-field")
    ;set population-field-y table-put population-field-y population (field-y * get-ball-population-property population "electric-field")
  ]
end

;;if population > length ball-population-properties [foreach (range length ball-population-properties population 1) [index -> set ball-population-properties insert-item index ball-population-properties [] ]]
to erase-field [-field-number]
  ask patches with [field-number = -field-number]
  [
    ask arrows-here [die]
    set field-number 0
    set isPainted FALSE
    set field-x  0
    set field-y  0
    set accum-x  0
    set accum-y  0
    set accum-w  0
    set population-field-x n-values length population-numbers [0]
    set population-field-y n-values length population-numbers [0]
    ;foreach population-numbers [population -> table:put population-field-x population 0 table:put population-field-y population 0]
    ;foreach population-numbers [population -> set population-field-x table-put population-field-x population 0 set population-field-y table-put population-field-y population 0]
    recolor-patch
  ]
  set field-count max [field-number] of patches
end

to-report has-field
  report field-number > 0
end

to recolor-patch
  (ifelse
    has-wall [set pcolor wall-color ]
    has-field [set pcolor field-color ]
    [set pcolor current-background-color] )
end

to paint-world
    set current-background-color background-color
    paint-patches
    if (prev-command-name != "paint-world") [
          log-output "paint-world"]
end

to paint-patches
  ask patches [recolor-patch]
end

to advance-balls-in-world
  ask balls [
    ; if nextpatch == wall then call perform-hit-wall
    ; if in same patch as other ball - call  perform-meet-ball
    ; Then move
    factor-field ; add change of speed and heading due to electric field
    factor-field-interaction
    factor-gravity;
    check-for-wall ;  changes speed and heading when ball meets wall
    check-for-collision  ; changes speed and heading when 2 balls meet

    ; now move one step with updated heading and speed.
  ]  ; end of askballs
  ask balls [
    move
    recolor
  ]
end

to remove-flashes-past-their-lifespan
  ask flashes with [ticks - birthday > flash-time * tick-advance-amount] [die]
end

to-report any-moving-balls?
  let any-ball-moving false
  ask balls [if is-ball-moving? [set any-ball-moving true stop]]
  report any-ball-moving;
end

to update-display
  if tick-count mod 2 = 0 [display]
end

to advance-ticks
  tick-advance tick-advance-amount
  set tick-count tick-count + 1
end

to log-go-procedure
  if (test-if-log-output "play" = TRUE) [  ; test that prev logging is not exactly the same
    log-output "play"
    log_picture
  ]
end

to re-enable-movement-for-balls-predefined-to-move-limited-number-of-ticks
  ask balls with [is-number? move-forward] [set tick-count-move-enabled tick-count]
end

to update-ball-populaiton-properties-defined-in-nettango-blocks
  ; in order to apply changes to blocks, every turn the population properties are initialized
  ; and reset. The reason is that if a block is removed, then the option for that property must
  ; be set to default, which is done by initializing all population properties and reapplying
  ; properties of remaining blocks.

  let pop1-electric-field get-ball-population-property 1 "electric-field"
  let pop2-electric-field get-ball-population-property 2 "electric-field"
  initialize-ball-population-properties 1
  initialize-ball-population-properties 2
  configure-population-1
  configure-population-2
  if pop1-electric-field != get-ball-population-property 1 "electric-field" [recalculate-field-values-for-population 1]
  if pop2-electric-field != get-ball-population-property 2 "electric-field" [recalculate-field-values-for-population 2]
end

;to time-run
;  if tick-count = 0 [profiler:reset profiler:start]
;  if tick-count = 500 [print profiler:report profiler:reset]
;end

to go
  ;time-run
  log-go-procedure
  update-ball-populaiton-properties-defined-in-nettango-blocks
  ifelse any-moving-balls? [
    every (tick-advance-amount) [
      ;update-electricity
      advance-balls-in-world
      remove-flashes-past-their-lifespan
      advance-ticks
      update-display
    ]
  ][
    stop  ;; unselect "play" button
    re-enable-movement-for-balls-predefined-to-move-limited-number-of-ticks
  ]
  set brush-activated-after-model-was-advanced false
end

to color-population-by-speed [population]
  ;refactor this procedure very slow, n^2 complexity
  let lower-limit 0
  let upper-limit 0

  let values [speed] of balls with [population-num = population]
  if (length values > 1)
  [  set lower-limit mean values - 3 * standard-deviation values
     set upper-limit mean values + 3 * standard-deviation values
     ask balls with [population-num = 1]
     [   set color scale-color color speed (lower-limit - 1) (upper-limit + 1)
     ]
  ]
end

to recolor  ;; particle procedure
  ifelse Color-Speed [
    foreach population-numbers [population -> color-population-by-speed population] ]
  [
    set color [initial-color] of self
  ]
end

; ball procedure
to-report is-ball-moving?
  let -move-forward move-forward
  report ifelse-value is-boolean? -move-forward [-move-forward] [tick-count - tick-count-move-enabled < -move-forward]
end

; turtle procedure
to flash-counter-here
  if [has-counter] of patch-here [
    ask patch-here [flash-patch black] ]
end

; patch procedure
to-report has-flash
  report any? flashes-here
end

; patch procedure
to create-flash-here [-flash-color]
  sprout-flashes 1 [
    set color -flash-color
    set birthday ticks
  ]
end

; patch procedure
to flash-patch [-flash-color]
  ifelse has-flash [
    renew-lifespan-of-flash-here ]
  [
    create-flash-here -flash-color
  ]
end

; patch procedure
to renew-lifespan-of-flash-here
  ask one-of flashes-here [set birthday ticks]
end

to set-ball-xy-to-return-cyclically-around-world
  set xcor (((xcor + max-pxcor) mod (2 * max-pxcor)) - max-pxcor)
  set ycor (((ycor + max-pycor) mod (2 * max-pycor)) - max-pycor)
end

to-report is-ball-being-traced
  report pen-mode = "down"
end

to return-ball-cyclically-around-world
  ifelse is-ball-being-traced [
    pen-up
    set-ball-xy-to-return-cyclically-around-world
    pen-down ]
  [
    set-ball-xy-to-return-cyclically-around-world
  ]
end

to move ;; particle procedure

  if is-ball-moving?
  [
    ; if ball on counter  - create a flash
    ;  counters-report   ; changed to count flashes and not balls on counters bcs too many ticks balls are on counter
    if (counter-count > 0)
    [  ifelse (any? counters-here) and (on-counter = False) [  ; if there is a counter at the pos of the ball (we are inside ask balls in go) and ball was not counted yet
        set on-counter True
        increase-counter counter-number-here
        flash-counter-here
      ]
      [ set on-counter False
      ]
    ] ; end if count-counters > 0


    ; look at th epatch the ball will be moving to:
      let pahead patch-ahead (speed * tick-advance-amount)
      ifelse (pahead = nobody)
      [ ; when ball leaves world - instead of die:
        ; if it is inside a efield then choose random location on an edge patch of that field and move ball to that new location.
        ; ensure that ball returns to same field-number
        ; if it is not inside an efield then it returns cyclically.
        ifelse field-count > 0  ; there is a field in the world
        [   let patches-on-edge patches with [(field-number = [field-number] of myself) and (pxcor = max-pxcor  or pxcor = min-pxcor  or pycor = max-pycor  or pycor = min-pycor) ]
            ifelse  (any? patches-on-edge)  ; there is atleast 1 patch marked at edge of world
            [ let  new-patch one-of patches-on-edge   ;
              set xcor  [pxcor] of new-patch
              set ycor  [pycor] of new-patch
              if (([field-x] of new-patch != 0) or ([field-y] of new-patch != 0))
               [ set heading atan [field-x] of new-patch  [field-y] of new-patch
               ]
               ; otherwise continue in same direction as exited window
            ]
            [ ; else there are no patches of field on edge of world, ball returns cyclic
                return-ball-cyclically-around-world
            ]
         ] ; end if field-count > 0
         [  ; else - there is no efield balls return cyclic
           return-ball-cyclically-around-world
         ]
      ]
      ; ball did not leave the world - move it and deal with collision with other ball:
      [   if pahead != patch-here
                 [ set last-collision nobody ]
          jump (speed * tick-advance-amount)
      ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;bounce;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to   check-for-wall ;  if next to wall patch, change speed and heading of ball
;output-print "in check for wall"
;output-type (round heading)
;output-show (shade-of? blue [pcolor] of new-patch)
;clear-output

 let new-patch patch-ahead lookAhead ;  GIGI was look atnext patch but changed to look where ACTUALLY will be
;let new-patch patch-ahead (speed * tick-advance-amount)
let headingM  heading mod 360   ; ensure heading is 0..360

  if new-patch = nobody [stop]
;  if ( ([pxcor] of new-patch = max-pxcor ) or ([pxcor] of new-patch = min-pxcor ) or ([pycor] of new-patch = max-pycor ) or ([pycor] of new-patch = min-pycor ))  [stop]
if (headingM >= 0) and (headingM < 90)   ; Quadrant I check only right and up walls
[     let new-patch-right  patch-at-heading-and-distance  90 lookAhead
      let new-patch-up    patch-at-heading-and-distance    0 lookAhead
      if (new-patch-right = nobody) [set new-patch-right patch-here]  ; if at edge of world
      if (new-patch-up = nobody) [set new-patch-up patch-here]  ; if at edge of world

    if (([has-wall] of new-patch-right) and ([has-wall] of new-patch-up) ) [perform-hit-wall "corner" [pxcor] of new-patch-right [pycor] of new-patch-right stop]
      if ([has-wall] of new-patch-right)   [perform-hit-wall "right" [pxcor] of new-patch-right [pycor] of new-patch-right stop]
      if ([has-wall] of new-patch-up)     [perform-hit-wall "up" [pxcor] of new-patch-up [pycor] of new-patch-up stop]
      if ([has-wall] of new-patch)        [perform-hit-wall "corner" [pxcor] of new-patch [pycor] of new-patch stop]
]

if (headingM >= 90) and (headingM < 180)   ; Quadrant II check only right and down walls
[     let new-patch-right  patch-at-heading-and-distance   90 lookAhead
      let new-patch-down  patch-at-heading-and-distance  180 lookAhead
      if (new-patch-right = nobody) [set new-patch-right patch-here]  ; if at edge of world
      if (new-patch-down = nobody) [set new-patch-down patch-here]  ; if at edge of world

      if (([has-wall] of new-patch-right) and ([has-wall] of new-patch-down))  [perform-hit-wall "corner" [pxcor] of new-patch-right [pycor] of new-patch-right stop]
      if ([has-wall] of new-patch-right)   [perform-hit-wall "right" [pxcor] of new-patch-right [pycor] of new-patch-right stop]
      if ([has-wall] of new-patch-down)   [perform-hit-wall "down" [pxcor] of new-patch-down [pycor] of new-patch-down stop]
      if ([has-wall] of new-patch)        [perform-hit-wall "corner" [pxcor] of new-patch [pycor] of new-patch stop]
]

if (headingM >= 180) and (headingM < 270)   ; Quadrant III check only left and down walls
[     let new-patch-left  patch-at-heading-and-distance  -90 lookAhead
      let new-patch-down  patch-at-heading-and-distance  180 lookAhead
      if (new-patch-left = nobody) [set new-patch-left patch-here]  ; if at edge of world
      if (new-patch-down = nobody) [set new-patch-down patch-here]  ; if at edge of world

      if (([has-wall] of new-patch-left) and ([has-wall] of new-patch-down))  [perform-hit-wall "corner" [pxcor] of new-patch-left [pycor] of new-patch-left stop]
      if ([has-wall] of new-patch-left)   [perform-hit-wall "left" [pxcor] of new-patch-left [pycor] of new-patch-left stop]
      if ([has-wall] of new-patch-down)   [perform-hit-wall "down" [pxcor] of new-patch-down [pycor] of new-patch-down stop]
      if ([has-wall] of new-patch)        [perform-hit-wall "corner" [pxcor] of new-patch [pycor] of new-patch stop]
]

if (headingM >= 270) and (headingM < 360)   ; Quadrant IV check only left and up walls
[     let new-patch-left  patch-at-heading-and-distance  -90 lookAhead
      let new-patch-up    patch-at-heading-and-distance    0 lookAhead
      if (new-patch-left = nobody) [set new-patch-left patch-here]  ; if at edge of world
      if (new-patch-up = nobody) [set new-patch-up patch-here]  ; if at edge of world

      if (([has-wall] of new-patch-left) and ([has-wall] of new-patch-up)) [perform-hit-wall "corner" [pxcor] of new-patch-left [pycor] of new-patch-left stop]
      if ([has-wall] of new-patch-left)   [perform-hit-wall "left" [pxcor] of new-patch-left [pycor] of new-patch-left stop]
      if ([has-wall] of new-patch-up)     [perform-hit-wall "up" [pxcor] of new-patch-up [pycor] of new-patch-up stop]
      if ([has-wall] of new-patch)        [perform-hit-wall "corner" [pxcor] of new-patch [pycor] of new-patch stop]
]
end

;ball procedure
to change-heading-after-wall-collision [wall-direction xpos ypos]
  if (wall-collision-heading-change = "no change")[]
  if (wall-collision-heading-change = "turn left")[  set heading (heading - 90 ) ]
  if (wall-collision-heading-change = "turn right")[ set heading (heading + 90 )  ]
  if (wall-collision-heading-change = "bounce")[ bounce wall-direction  xpos ypos]  ; change heading (speed remains the same)
end

to change-speed-after-wall-collision
  if (wall-collision-speed-change = "zero")     [ set speed 0 ]
  if (wall-collision-speed-change = "increase")[set speed speed + deltaSpeed]
  if (wall-collision-speed-change = "decrease")[set speed speed - deltaSpeed]
  if (wall-collision-speed-change = "bounce") and (wall-collision-heading-change != "bounce")
                     [user-message (word "You cannot pair non-bounce heading change with bounce speed change.")]
end

to set-ball-speed-to-maximum-if-above-max-speed
  ; make sure speed does not exceed limit
  if (speed > max-speed) [set speed max-speed]
end

; patch procedure
to flash-wall-here
  if has-wall [
    flash-patch pcolor + 2 ]
end

to flash-wall-at [-xcor -ycor]
  if flash-wall-collision [
    ask patch -xcor -ycor [flash-wall-here] ]
end

to increase-wall-collision-count-for-ball-population
  let index (population-num - 1)
  set wall-collision-count replace-item index wall-collision-count (item index wall-collision-count + 1)
end

to perform-hit-wall [wall-direction xpos ypos]
  increase-wall-collision-count-for-ball-population
  flash-wall-at xpos ypos
  change-heading-after-wall-collision wall-direction xpos ypos
  change-speed-after-wall-collision
  set-ball-speed-to-maximum-if-above-max-speed
end

to bounce [direction xpos ypos]
;  sets new heading of ball when hits wall
;  direction is the direction of the wall from ball "left" "right" "up" "down" "corner"
; xpos ypox is the coordinate of the wall patch. Needed for flashing
;output-show "in bounce"

  if ((direction = "right") or (direction = "left")) [set heading (-1 * heading)]  ; hit a horizontal wall
  if ((direction = "up")    or (direction = "down")) [set heading (180 - heading)] ; hit vertical wall
  if (direction = "corner")                          [set heading (180 + heading)] ; hit wall at a corner
  set last-collision nobody
end

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;collision;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 to check-for-collision  ;; check if 2 balls collide. If so Change speed and heading of the 2 balls

  ;; Here we impose a rule that collisions only take place when there
  ;; are exactly two balls per patch.  We do this because when the
  ;; student introduces new balls from the side, we want them to
  ;; form a uniform wavefront.
  ;;
  ;; Why do we want a uniform wavefront?  Because it is actually more
  ;; realistic.  (And also because the curriculum uses the uniform
  ;; wavefront to help teach the relationship between ball collisions,
  ;; wall hits, and pressure.)
  ;;
  ;; Why is it realistic to assume a uniform wavefront?  Because in reality,
  ;; whether a collision takes place would depend on the actual headings
  ;; of the balls, not merely on their proximity.  Since the balls
  ;; in the wavefront have identical speeds and near-identical headings,
  ;; in reality they would not collide.  So even though the two-balls
  ;; rule is not itself realistic, it produces a realistic result.  Also,
  ;; unless the number of balls is extremely large, it is very rare
  ;; for three or more balls to land on the same patch (for example,
  ;; with 400 balls it happens less than 1% of the time).  So imposing
  ;; this additional rule should have only a negligible effect on the
  ;; aggregate behavior of the system.
  ;;
  ;; Why does this rule produce a uniform wavefront?  The balls all
  ;; start out on the same patch, which means that without the only-two
  ;; rule, they would all start colliding with each other immediately,
  ;; resulting in much random variation of speeds and headings.  With
  ;; the only-two rule, they are prevented from colliding with each other
  ;; until they have spread out a lot.  (And in fact, if you observe
  ;; the wavefront closely, you will see that it is not completely smooth,
  ;; because some collisions eventually do start occurring when it thins out while fanning.)
  let candidate 0
  let ourDistance 0
  let mySize  size
  let mySpeed speed
  let interBallMaxDist 0
;
  ; Collision occurs if there is a ball in the same patch at the borders of the balls  (GIGI at this point assume a ball can collide with only 1 ball)
    ;; the following conditions are imposed on collision candidates:
    ;;   1. they must have a lower who number than my own, because collision
    ;;      code is asymmetrical: it must always happen from the point of view
    ;;      of just one ball.
    ;;   2. they must not be the same ball that we last collided with on
    ;;      this patch, so that we have a chance to leave the patch after we've
    ;;      collided with someone.
  ;ask other balls
  ;ask other balls-here
  let -length abs ((round (xcor - (size / 2))) - (round (xcor + (size / 2) ))) + 1
  let top-left-xcor (round (xcor - (size / 2)))
  let top-left-ycor (round (ycor + (size / 2)))
  let my-who who
  ;ask (turtle-set n-values (-length ^ 2) [i -> [balls-here with [who < my-who]] of patch (top-left-xcor + i mod -length) (top-left-ycor - int(i / -length))])
  ask (turtle-set n-values (-length ^ 2) [i ->
  ifelse-value abs (top-left-xcor + i mod -length) < max-pxcor and abs (top-left-ycor - int(i / -length)) < max-pycor
                 [[balls-here with [who < my-who]] of patch (top-left-xcor + i mod -length) (top-left-ycor - int(i / -length))] [nobody]])
  ; other ball == candidate in older code
  [ set interBallMaxDist  ((size + mySize) / 2)
    set ourDistance  distance myself
    if (ourDistance <= interBallMaxDist  and ourDistance >= interBallMaxDist - eps-collision)    ; collision!!
       [ if (who < [who] of myself) and (myself != last-collision)  ; perform the collision if other ball number is smaller than me.
         [
            if TRUE ;(speed > 0 or mySpeed > 0)   ; at least one ball is moving
              [
                set candidate self   ; set candidate variabe as self so as to call perform-collision function
                ask myself [perform-collision candidate]
                set last-collision myself
                ask myself [set last-collision  candidate]
              ]
          ]

    ]
  ]
end

to-report balls-belong-to-same-population [ball1 ball2]
  report [population-num] of ball1 = [population-num] of ball2
end

;ball procedure
to perform-collision-with-ball-belonging-to-same-population [other-ball]
  perform-collision-heading-change-with-ball-belonging-to-same-population other-ball
  perform-collision-speed-change-with-ball-belonging-to-same-population other-ball
  set-ball-speed-to-maximum-if-above-max-speed
  ask other-ball [set-ball-speed-to-maximum-if-above-max-speed]
end

;ball procedure
to perform-collision-with-ball-belonging-to-different-population [other-ball]
  perform-collision-heading-change-with-ball-belonging-to-different-population other-ball
  perform-collision-speed-change-with-ball-belonging-to-different-population other-ball
  set-ball-speed-to-maximum-if-above-max-speed
  ask other-ball [set-ball-speed-to-maximum-if-above-max-speed]
end

;ball procedure
to perform-collision-heading-change-with-ball-belonging-to-same-population [other-ball]
  (ifelse
    (ball-collision-heading-change = "no change")[]
    (ball-collision-heading-change = "turn left")[  set heading (heading - 90) ask other-ball [set heading (heading - 90)]]
    (ball-collision-heading-change = "turn right")[ set heading (heading + 90 ) ask other-ball [set heading (heading + 90)]]
    ((ball-collision-heading-change = "collide") and (ball-collision-speed-change = "collide")) [collide-with other-ball ]   ; changes heading and speed of BOTH  balls
    ((ball-collision-heading-change = "attract") and (ball-collision-speed-change = "attract")) [collide-with other-ball ]   ; changes heading and speed of BOTH  balls
  )
end

;ball procedure
to perform-collision-speed-change-with-ball-belonging-to-same-population [other-ball]
  (ifelse
    (ball-collision-speed-change = "zero")    [set speed 0 ask other-ball [set speed 0]]
    (ball-collision-speed-change = "increase")[set speed speed + deltaSpeed ask other-ball [set speed speed + deltaSpeed]]
    (ball-collision-speed-change = "decrease")[set speed speed - deltaSpeed ask other-ball [set speed speed - deltaSpeed]]
    ((ball-collision-speed-change = "collide") and (ball-collision-heading-change != "collide")) or ((ball-collision-speed-change != "collide") and (ball-collision-heading-change = "collide"))
                      [user-message (word "You cannot pair non-collision heading change with collision speed change.")]
    ((ball-collision-speed-change = "attract") and (ball-collision-heading-change != "attract")) or ((ball-collision-speed-change != "attract") and (ball-collision-heading-change = "attract"))
                      [user-message (word "You cannot pair non-attraction heading change with attraction speed change.")]
  )
end

;ball procedure
to perform-collision-heading-change-with-ball-belonging-to-different-population [other-ball]
  (ifelse
    (ball-collision-different-populations-heading-change = "no change")[]
    (ball-collision-different-populations-heading-change = "turn left")[ set heading (heading - 90) ask other-ball [set heading (heading - 90)]]
    (ball-collision-different-populations-heading-change = "turn right")[ set heading (heading + 90 ) ask other-ball [set heading (heading + 90)]]
    ((ball-collision-different-populations-heading-change = "collide") and (ball-collision-different-populations-speed-change = "collide")) [collide-with other-ball ]   ; changes heading and speed of BOTH  balls
    ((ball-collision-different-populations-heading-change = "attract") and (ball-collision-different-populations-speed-change = "attract")) [ collide-with other-ball ]   ; changes heading and speed of BOTH  balls
  )
end

;ball procedure
to perform-collision-speed-change-with-ball-belonging-to-different-population [other-ball]
  (ifelse
    (ball-collision-different-populations-speed-change = "zero")     [ set speed 0 ask other-ball[set speed 0]]
    (ball-collision-different-populations-speed-change = "increase")[set speed speed + deltaSpeed ask other-ball[set speed speed + deltaSpeed]]
    (ball-collision-different-populations-speed-change = "decrease")[set speed speed - deltaSpeed ask other-ball[set speed speed - deltaSpeed]]
    ((ball-collision-different-populations-speed-change = "collide") and (ball-collision-different-populations-heading-change != "collide")) or
            ((ball-collision-different-populations-speed-change != "collide") and (ball-collision-different-populations-heading-change = "collide"))
            [user-message (word "You cannot pair non-collision heading change with collision speed change.")]
    ((ball-collision-different-populations-speed-change = "attract") and (ball-collision-different-populations-heading-change != "attract")) or
            ((ball-collision-different-populations-speed-change != "attract") and (ball-collision-different-populations-heading-change = "attract"))
            [user-message (word "You cannot pair non-attraction heading change with attraction speed change.")]
  )
end

;ball procedure
to perform-collision [other-ball]
;  when self and candidate balls meet will change the heading and speed of both balls
  ifelse balls-belong-to-same-population self other-ball [
    perform-collision-with-ball-belonging-to-same-population other-ball ]
  [
    perform-collision-with-ball-belonging-to-different-population other-ball
  ]
end

to collide-with [ other-ball ] ;;
;; implements a collision with another ball.
;;
;; THIS IS THE HEART OF THE PARTICLE SIMULATION, AND YOU ARE STRONGLY ADVISED
;; NOT TO CHANGE IT UNLESS YOU REALLY UNDERSTAND WHAT YOU'RE DOING!
;;
;; The two balls colliding are self and other-ball, and while the
;; collision is performed from the point of view of self, both balls are
;; modified to reflect its effects. This is somewhat complicated, so I'll
;; give a general outline here:
;;   1. Do initial setup, and determine the heading between ball centers
;;      (call it theta).
;;   2. Convert the representation of the velocity of each ball from
;;      speed/heading to a theta-based vector whose first component is the
;;      ball's speed along theta, and whose second component is the speed
;;      perpendicular to theta.
;;   3. Modify the velocity vectors to reflect the effects of the collision.
;;      This involves:
;;        a. computing the velocity of the center of mass of the whole system
;;           along direction theta
;;        b. updating the along-theta components of the two velocity vectors.
;;   4. Convert from the theta-based vector representation of velocity back to
;;      the usual speed/heading representation for each ball.
;;   5. Perform final cleanup and update derived quantities.

  let mass2 0
  let speed2 0
  let heading2 0
  let theta 0
  let v1t 0
  let v1l 0
  let v2t 0
  let v2l 0
  let vcm 0

;output-print "me in collide with"
;  output-print population-num
;  output-print speed
;  output-print heading
;
;  output-print "other ball"
; output-print  [population-num] of other-ball
;  output-print [speed] of other-ball
; output-print [heading] of other-ball


  ;; Step 0 - If one of the populations shouldnt move (==ballsX-forward == FALSE) the other ball should bounce bck (heading = -heading)
  ;; Actually we enter here with myself is moving. Cant be that my balls-forward is FALSE
  ;refactor
  let this-ball-is-moving is-ball-moving?
  let other-ball-is-moving [is-ball-moving?] of other-ball
  let both-balls-are-moving ifelse-value this-ball-is-moving and other-ball-is-moving [true] [false]

  if not this-ball-is-moving [
    ask other-ball [ set heading heading + 180  ] ; heading is reflected but speed remains the same and my speed+heading doesnt change (but is irrelevt anyway)
  ]

  if not other-ball-is-moving [
    set heading  heading + 180  ; heading is reflected but speed remains the same and my speed+heading doesnt change (but is irrelevt anyway)
  ]

  if both-balls-are-moving
  [

  ;;; PHASE 1: initial setup

  ;; for convenience, grab some quantities from other-ball
  set mass2 [mass] of other-ball
  set speed2 [speed] of other-ball
  set heading2 [heading] of other-ball

  ;; since balls are modeled as zero-size points, theta isn't meaningfully
  ;; defined. we can assign it randomly without affecting the model's outcome.
  set theta (random-float 360)



  ;;; PHASE 2: convert velocities to theta-based vector representation

  ;; now convert my velocity from speed/heading representation to components
  ;; along theta and perpendicular to theta
  set v1t (speed * cos (theta - heading))
  set v1l (speed * sin (theta - heading))

  ;; do the same for other-ball
  set v2t (speed2 * cos (theta - heading2))
  set v2l (speed2 * sin (theta - heading2))



  ;;; PHASE 3: manipulate vectors to implement collision

  ;; compute the velocity of the system's center of mass along theta
  set vcm (((mass * v1t) + (mass2 * v2t)) / (mass + mass2) )

  ;; now compute the new velocity for each ball along direction theta.
  ;; velocity perpendicular to theta is unaffected by a collision along theta,
  ;; so the next two lines actually implement the collision itself, in the
  ;; sense that the effects of the collision are exactly the following changes
  ;; in ball velocity.
  set v1t (2 * vcm - v1t)
  set v2t (2 * vcm - v2t)

;  output-print "me after"
;  output-print population-num
;  output-print speed
;  output-print heading
;
;  output-print "other ball after "
; output-print  [population-num] of other-ball
;  output-print [speed] of other-ball
; output-print [heading] of other-ball

  ;;; PHASE 4: convert back to normal speed/heading

  ;; now convert my velocity vector into my new speed and heading
  set speed sqrt ((v1t * v1t) + (v1l * v1l))
  ;; if the magnitude of the velocity vector is 0, atan is undefined. but
  ;; speed will be 0, so heading is irrelevant anyway. therefore, in that
  ;; case we'll just leave it unmodified.
   ; make sure speed does not exceed limit
   if (speed > max-speed) [set speed max-speed]
   if v1l != 0 or v1t != 0
    [ set heading (theta - (atan v1l v1t)) ]

  ;; and do the same for other-ball
  ask other-ball [
    set speed sqrt ((v2t ^ 2) + (v2l ^ 2))
    ; make sure speed does not exceed limit
    if (speed > max-speed) [set speed max-speed]
    if v2l != 0 or v2t != 0
      [ set heading (theta - (atan v2l v2t)) ]
  ]

  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GRAVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-electricity   ;; updates the per patch gravity field vector by adding the fields for each ball
  let ball-pos-x 0
  let ball-pos-y 0
  let dist 0
  let max-electric-strength 10  ;; this needs to become a global variable set from a button in the interface
  let patch-list []
  set patch-list patches

  ;; first null the electric field
  ask patches [
     set field-x  0
     set field-y  0
  ]

  ask balls
  [
      ask patch-list [
;  [ foreach patch in-radius 10000 [
    set field-x  field-x + 1
;    ]
  ]
  ]
;   ;; per ball update the electric field in each patch
 ask balls [
    set ball-pos-x xcor
    set ball-pos-y ycor

    ask patch-list [
      set dist  sqrt max ( list ((pxcor - ball-pos-x) ^ 2 + (pycor - ball-pos-y) ^ 2)  1)   ; dist holds distance to patch but does not alllow 0
;output-print  dist

      set field-x  (field-x +   (pxcor - ball-pos-x) / (dist ^ 3)  * max-electric-strength)
      set field-y  (field-y +   (pycor - ball-pos-y) / (dist ^ 3)  * max-electric-strength)
  ]

  ]
end

to-report is-ball-affected-by-repel-or-attract-forces
  let own-population-interaction ball-collision-heading-change
  ; affected by my own population?
  if own-population-interaction = "repel" or own-population-interaction = "attract" or own-population-interaction = "repel and attract" [report true]
  ; affected by other population?
  foreach (remove-item (population-num - 1) population-numbers) [population -> if population-repels-or-attracts-other-populations? population [report true]]
  report false
end

to factor-field-interaction  ;; turtle procedure consider the electric field
  if is-ball-affected-by-repel-or-attract-forces [
    let my-field-x 0 ; null my field data
    let my-field-y 0 ; null my field data

    let  mypos-x xcor
    let  mypos-y ycor
    let dist 0  ; will be used to calculate distance between balls
    let force 0 ; will hold the LJ force between 2 balls

    ask other balls
    [ ifelse balls-belong-to-same-population myself self [
      if ((ball-collision-heading-change = "repel") and (ball-collision-speed-change = "repel")) [ ; add repulsion factor to my field
        set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
        set my-field-x  (my-field-x -   (xcor - mypos-x) / (dist ^ 3)  * repulsion-strength)
        set my-field-y  (my-field-y -   (ycor - mypos-y) / (dist ^ 3)  * repulsion-strength)
      ]
      if ((ball-collision-heading-change = "attract") and (ball-collision-speed-change = "attract")) [ ; add attraction factor to my field
        set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
        set my-field-x  (my-field-x  +   (xcor - mypos-x) / (dist ^ 3)  * attraction-strength)
        set my-field-y  (my-field-y  +   (ycor - mypos-y) / (dist ^ 3)  * attraction-strength)
      ]
      if ((ball-collision-heading-change = "repel and attract") and (ball-collision-speed-change = "repel and attract")) [ ; add leonard-Jones factor to my field
        set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
        set LJsigma size  ; set this LJ param to be size of ball
        set force ((24 * LJeps / LJsigma ^ 2 * ( 2 * (LJsigma / (dist )) ^ 14 - (LJsigma / (dist)) ^ 8 ) ))  ;LJ formula from Eilon's code
                                                                                                             ;output-print (word "force = " force  " dist = "  dist )
        set my-field-x  (my-field-x    - force *  (xcor - mypos-x) / (dist))     ; (xcor - mypos-x) / (dist)  is sin(theta)
        set my-field-y  (my-field-y    - force *  (ycor - mypos-y) / (dist))     ; (ycor - mypos-y) / (dist)  is cos(theta)
      ]
      ]

      [(ifelse
        ((ball-collision-different-populations-heading-change = "repel") and (ball-collision-different-populations-speed-change = "repel")) [ ; add repulsion factor to my field
          set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
          set my-field-x  (my-field-x -   (xcor - mypos-x) / (dist ^ 3)  * repulsion-strength)
          set my-field-y  (my-field-y -   (ycor - mypos-y) / (dist ^ 3)  * repulsion-strength)
        ]
        ((ball-collision-different-populations-heading-change = "attract") and (ball-collision-different-populations-speed-change = "attract")) [ ; add attraction factor to my field
          set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
          set my-field-x  (my-field-x  +   (xcor - mypos-x) / (dist ^ 3)  * attraction-strength)
          set my-field-y  (my-field-y  +   (ycor - mypos-y) / (dist ^ 3)  * attraction-strength)

        ]
        ((ball-collision-different-populations-heading-change = "repel and attract") and (ball-collision-different-populations-speed-change = "repel and attract")) [ ; add leonard-Jones factor to my field
          set dist  sqrt max ( list ((xcor - mypos-x) ^ 2 + (ycor - mypos-y) ^ 2) 1)  ; dist holds distance to patch but does not alllow 0
          set LJsigma size  ; set this LJ param to be size of ball
          set force ((24 * LJeps / LJsigma ^ 2 * ( 2 * (LJsigma / (dist )) ^ 14 - (LJsigma / (dist)) ^ 8 ) ))  ;LJ formula from Eilon's code
          set my-field-x  (my-field-x    - force * (xcor - mypos-x) / (dist))     ; (xcor - mypos-x) / (dist)  is sin(theta)
          set my-field-y  (my-field-y    - force * (ycor - mypos-y) / (dist))     ; (ycor - mypos-y) / (dist)  is cos(theta)
        ]

      )]


    ]

    let vx (sin heading * speed) + (my-field-x * tick-advance-amount)
    let vy (cos heading * speed) + (my-field-y * tick-advance-amount)
    set speed sqrt ((vy ^ 2) + (vx ^ 2))
    ; if (speed > max-speed) [set speed max-speed]
    if ((vx != 0) or (vy != 0))  [set heading atan vx vy]
  ]
end

to factor-field  ;; turtle procedure consider the electric field
                 ;output-print "inside FACTOR FIELD"
                 ;output-print (word "field of patch " [field-x] of patch-here " " [field-y] of patch-here)
                 ;output-print (word " patch xy : " [pxcor] of patch-here  [pycor] of patch-here)
  if field-count > 0 [
    let ball-population-number population-num
    let vx ((sin heading) * speed) + ([item (ball-population-number - 1) population-field-x] of patch-here  * tick-advance-amount)
    let vy ((cos heading) * speed) + ([item (ball-population-number - 1) population-field-y] of patch-here  * tick-advance-amount)
    ;let vx ((sin heading) * speed) + ([table:get population-field-x ball-population-number] of patch-here  * tick-advance-amount)
    ;let vy ((cos heading) * speed) + ([table:get population-field-y ball-population-number] of patch-here  * tick-advance-amount)
    ;let vx ((sin heading) * speed) + ([table-get population-field-x ball-population-number] of patch-here  * tick-advance-amount)
    ;let vy ((cos heading) * speed) + ([table-get population-field-y ball-population-number] of patch-here  * tick-advance-amount)
    set speed sqrt ((vy ^ 2) + (vx ^ 2))
    ;set-ball-speed-to-maximum-if-above-max-speed
    if ((vx != 0) or (vy != 0))  [set heading atan vx vy]
  ]
end

to factor-gravity  ;; turtle procedure
  if (not is-affected-by-gravity) [stop]  ; no gravity field - return

  if speed = 0 [stop]  ; GIGI - why? if speed is 0 then should increase by gravity...
  let vx (sin heading * speed) + (gravity-acceleration-x * tick-advance-amount)
  ;let vy (cos heading * speed) + (gravity-acceleration-y * tick-advance-amount)
  let vy (cos heading * speed) + ((- ball-gravity-acceleration) * tick-advance-amount)
  set speed sqrt ((vy ^ 2) + (vx ^ 2))
  set-ball-speed-to-maximum-if-above-max-speed
  set heading atan vx vy
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;STICK;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;to stick
;  set stick-to-wall? true
;        set leader self
;  if has-wall [set stuck-on-wall? true]
;
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;earser;;;;;;;;;;;;;;;

to start-new-task   ; called from START NEW TASK button
  clear-all
  set-global-values
  initialize-properties-for-first-n-ball-populations 2
  update-ball-populaiton-properties-defined-in-nettango-blocks
  ;crt-pop
  select-next-population-in-properties-ui
  setup-brush
  paint-patches
  reset-ticks
end;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LOGGING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report delimit [-left delimiter -right]
  report (word -left delimiter -right)
end

to-report delimit-comma [-left -right]
  report delimit -left "," -right
end

to-report delimit-hashtag [-left -right]
  report delimit -left ",#," -right
end

to-report delimited-population-settings [population -settings]
  report reduce delimit-comma map [property -> get-ball-population-property population property] -settings
end

to-report delimited-all-populations-settings [-settings]
  report reduce delimit-hashtag map [population -> delimited-population-settings population -settings] population-numbers
end

to-report delimited-all-populations-numerous-settings [settings-list]
  report reduce delimit-hashtag map [settings -> delimited-all-populations-settings settings] settings-list
end

to-report populations-settings-delimited-string
  let properties ["initial-size" "initial-color" "initial-speed" "initial-heading"]
  let actions ["move-forward"]
  let interactions ["if-ball-meets-wall-heading" "if-ball-meets-wall-speed" "if-ball-meets-ball-heading" "if-ball-meets-ball-speed"
        "if-ball-meets-ball-other-population-heading" "if-ball-meets-ball-other-population-speed" "gravity" "electric-field"]
  report delimited-all-populations-numerous-settings (list properties actions interactions)
end

to-report population-count [population]
  report count balls with [population-num = population]
end

to-report amount-of-balls-being-traced
  report count balls with [pen-mode = "down"]
end

to-report delimited-population-count
  report reduce delimit-comma map population-count population-numbers
end

to-report delimited-log-string
  report (word populations-settings-delimited-string "," amount-of-balls-being-traced "," delimited-population-count "," current-background-color)
end

to-report log-header
   report (word " Date = "  date-and-time " , Command Name, ticks, ball1-Properties,  balls1-Size,balls1-color,balls1-init-speed,balls1-init-heading,"
                " balls2-Properties , balls2-Size,balls2-color,balls2-init-speed,balls2-init-heading,"
                "balls1-Actions , balls1-forward , balls2-Actions , balls2-forward,"
                " balls1-Interactions, if-hit-wall-heading1,if-hit-wall-speed1,if-meet-ball-heading1,if-meet-ball-speed1"
                ", balls2-Interactions,if-hit-wall-heading2,if-hit-wall-speed2,if-meet-ball-heading2,if-meet-ball-speed2 , "
                " balls1&balls2-Interactions ,if-meet-ball-heading ,if-meet-ball-speed , , trace-a-ball? ,num-balls1 , num-balls2 , background-color, Electric-Field-Strength,"
                " Gravity-field " )
end

to set-new-log-filename [fileName]
  let timestamp date-and-time
  let timestamp-no-colon replace-item 2 timestamp "-"
  set timestamp-no-colon replace-item 5 timestamp-no-colon "-"
  set log-filename (word fileName "_" substring timestamp-no-colon 16 27 "_" substring timestamp-no-colon 0 8 ".csv")
end

to setup-logging  [fileName]
  set-new-log-filename fileName
  if log-enabled [
    set log-history log-header
    send-to:file log-filename log-history
  ]
end

to set-new-log-photo-filename
  set log-filename-photo (word substring log-filename 0 (length log-filename - 4) "_" log-picture-count ".png")
end

to log_picture
  if log-enabled [
    set-new-log-photo-filename
    export-view log-filename-photo
  ]
end

to-report test-if-log-output [command-name]
  ifelse log-enabled [
    let new-line (word command-name  ",#," delimited-log-string)
    ifelse (new-line = prev-line) [report FALSE] [report TRUE]
  ] [report false]
end

to add-log-history [new-log]
 set log-history word log-history new-log
end

to log-output [command-name]
  if log-enabled [
    add-log-history (word timer "," command-name "," ticks ",#," delimited-log-string)
    send-to:file log-filename log-history
  set prev-command-name command-name
  set prev-line (word command-name  ",#,"  delimited-log-string)
  ]
end


to make-halo  ;; runner procedure
  ;; when you use HATCH, the new turtle inherits the
  ;; characteristics of the parent.  so the halo will
  ;; be the same color as the turtle it encircles (unless
  ;; you add code to change it
  hatch-halos 1
  [ set size 5
    ;; Use an RGB color to make halo three fourths transparent
    set color lput 64 extract-rgb color
    ;; set thickness of halo to half a patch
    ;__set-line-thickness 0.5 ;refactor nlw doesnt support this
    ;; We create an invisible directed link from the runner
    ;; to the halo.  Using tie means that whenever the
    ;; runner moves, the halo moves with it.
    create-link-from myself
    [ tie
      hide-link ] ]
  if (prev-command-name != "make-halo") [
    log-output "make-halo"]

end

to save-existing-layout
  let file-name user-input "איזה שם לתת לקובץ?"
  export-world (word file-name)
  if (prev-command-name != "save-existing-layout") [log-output "save-existing-layout"]
end

to load-existing-layout
  fetch:user-file-async [text ->
    if not (text = false) [
      carefully [
        import-a:world text
      ] [
        user-message "אין אפשרות לטעון את הקובץ"
      ]
    ]
  ]
  if (prev-command-name != "load-existing-layout") [log-output "load-existing-layout"]
end

;patch procedure
to-report patch-has-wall
  report has-wall
end

;patch procedure
to-report patch-has-balls
  report count balls-here > 0
end

;patch procedure
to-report can-attempt-to-create-wall-in-patch
  report not patch-has-wall
end

; patch procedure
to try-to-push-aside-balls-from-patch
  ask balls-here [try-to-move-to-closest-unblocked-neighbors4-patch]
end

;turtle procedure
to try-to-move-to-closest-unblocked-neighbors4-patch
  let closest-unblocked-neighbor-patch closest-unblocked-neighbors4-patch self
  let unblocked-neighbor-exists closest-unblocked-neighbor-patch != nobody
  if unblocked-neighbor-exists [
    move-to closest-unblocked-neighbor-patch
    forward random-float 0.01
  ]
end

to-report closest-unblocked-neighbors4-patch [-turtle]
  let patch-turtle-is-on [patch-here] of -turtle
  report min-one-of unblocked-neighbor4-patches patch-turtle-is-on [distance patch-turtle-is-on]
end

to-report unblocked-neighbor4-patches [-patch]
  report ([neighbors4] of -patch) with [not patch-has-wall]
end

to-report can-create-wall-in-patch
  report (not patch-has-wall) and (not patch-has-balls)
end

;patch procedure
to create-wall-in-patch
  if can-attempt-to-create-wall-in-patch [
    try-to-push-aside-balls-from-patch
    if can-create-wall-in-patch [
      set has-wall true
      set pcolor wall-color
    ]
  ]
end

; patch procedure
to remove-wall-in-patch
  if patch-has-wall [
    set has-wall false
    set pcolor background-color
  ]
end

to erase-all-balls-of-population-selected-in-ui
  if is-a-population-selected-in-ui [ask balls with [population-num = population-to-set-properties-for-in-ui] [remove-ball]]
end

;======== BRUSH ===========================

to setup-brush
  set mouse-down?-when-brush-was-last-activated false
  set mousexy-when-brush-was-last-activated [ ]
  set patches-drawn-on-since-brush-was-held-down no-patches
  set current-mousexy (list mouse-xcor mouse-ycor)
  set current-mouse-down? mouse-down?
  set current-mouse-inside?  mouse-inside?
  set brush-in-draw-mode true
  set brush-style "free-form"
  set brush-shape "square"
  set brush-type "wall"
  set brush-icon-size 4
  set shape-drawn-by-brush "rectangle"
  set center-patch-of-drawn-shape nobody
  set patches-affected-by-drawn-shape no-patches
  set brush-icon-transparency-normalized 0.8
  set gfx-displaying-patches-affected-by-drawn-shape no-turtles
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

to draw-with-brush
  (ifelse
    brush-style = "free-form" [draw-with-free-form-brush]
    brush-style = "shape" [draw-shape-with-brush])
end

to draw-shape-with-brush
  (ifelse
    is-brush-pressed-down [configure-new-shape-with-brush]
    brush-is-held-down [configure-current-shape-with-brush]
    brush-has-been-clicked [draw-shape-configured-by-brush remove-gfx-display-of-patches-to-be-affected-by-drawn-shape log-shape-drawn] )
end

to set-center-for-drawn-shape
  set center-patch-of-drawn-shape patch-under-brush
end

to configure-new-shape-with-brush
  set-center-for-drawn-shape
  set patches-affected-by-drawn-shape patch-set patch-under-brush
  update-display-of-patches-to-be-affected-by-drawn-shape
end

to configure-current-shape-with-brush
  if is-new-size-configured-for-drawn-shape [
    set-patches-to-be-affected-by-current-drawn-shape-configuration
    update-display-of-patches-to-be-affected-by-drawn-shape
  ]
end

to-report is-new-size-configured-for-drawn-shape
  let current-distance-of-patch-under-brush-from-shape-center [distance center-patch-of-drawn-shape] of patch-under-brush
  let former-distance-of-patch-under-brush-from-shape-center [distance center-patch-of-drawn-shape] of (patch-at-point mousexy-when-brush-was-last-activated)
  report current-distance-of-patch-under-brush-from-shape-center != former-distance-of-patch-under-brush-from-shape-center
end

to update-display-of-patches-to-be-affected-by-drawn-shape
  remove-gfx-display-of-patches-to-be-affected-by-drawn-shape
  add-gfx-display-of-patches-to-be-affected-by-drawn-shape
end

to remove-gfx-display-of-patches-to-be-affected-by-drawn-shape
  ask gfx-displaying-patches-affected-by-drawn-shape [die]
end

to add-gfx-display-of-patches-to-be-affected-by-drawn-shape
  ask patches-affected-by-drawn-shape [visually-display-this-patch-as-affected-by-drawn-shape]
end

to visually-display-this-patch-as-affected-by-drawn-shape
  sprout-gfx-overlay 1 [
    set shape "square"
    set color yellow
    set gfx-displaying-patches-affected-by-drawn-shape (turtle-set gfx-displaying-patches-affected-by-drawn-shape self)
  ]
end

to set-patches-to-be-affected-by-current-drawn-shape-configuration
  (ifelse
    shape-drawn-by-brush = "circle" [set-patches-to-be-affected-by-current-drawn-circle-configuration ]
    shape-drawn-by-brush = "rectangle" [set-patches-to-be-affected-by-current-drawn-rectangle-configuration ]
    shape-drawn-by-brush = "square" [set-patches-to-be-affected-by-current-drawn-square-configuration ]
    shape-drawn-by-brush = "line" [set-patches-to-be-affected-by-current-drawn-line-configuration ] )
end

to-report radius-of-circle-drawn-by-brush
  report [distance center-patch-of-drawn-shape] of patch-under-brush
end

to-report size-of-square-drawn-by-brush
  report (max list delta-pxcor center-patch-of-drawn-shape patch-under-brush delta-pycor center-patch-of-drawn-shape patch-under-brush)
end

to-report delta-pycor [patch1 patch2]
  report abs ([pycor] of patch1 - [pycor] of patch2)
end

to-report delta-pxcor [patch1 patch2]
  report abs ([pxcor] of patch1 - [pxcor] of patch2)
end

to set-patches-to-be-affected-by-current-drawn-line-configuration
  let point1 (list [pxcor] of center-patch-of-drawn-shape [pycor] of center-patch-of-drawn-shape)
  ;set patches-affected-by-drawn-shape patches-line-intersects point1 current-mousexy
  set patches-affected-by-drawn-shape patches-line-intersects item 0 point1 item 1 point1 item 0 current-mousexy item 1 current-mousexy
end

to set-patches-to-be-affected-by-current-drawn-rectangle-configuration
  let corner-xcor-delta-from-center delta-pxcor center-patch-of-drawn-shape patch-under-brush
  let corner-ycor-delta-from-center delta-pycor center-patch-of-drawn-shape patch-under-brush
  let width (corner-xcor-delta-from-center * 2) + 1
  let height (corner-ycor-delta-from-center * 2) + 1
  set patches-affected-by-drawn-shape (patch-set
    n-values height [right-side-ycor-delta-from-top -> [patch-at (corner-xcor-delta-from-center) (corner-ycor-delta-from-center - right-side-ycor-delta-from-top)] of center-patch-of-drawn-shape]
    n-values height [left-side-ycor-delta-from-top -> [patch-at (-1 * corner-xcor-delta-from-center) (corner-ycor-delta-from-center - left-side-ycor-delta-from-top)] of center-patch-of-drawn-shape]
    n-values width [top-side-xcor-delta-from-left -> [patch-at ((-1 * corner-xcor-delta-from-center) + top-side-xcor-delta-from-left) (corner-ycor-delta-from-center)] of center-patch-of-drawn-shape]
    n-values width [bottom-side-xcor-delta-from-left -> [patch-at ((-1 * corner-xcor-delta-from-center) + bottom-side-xcor-delta-from-left) (-1 * corner-ycor-delta-from-center)] of center-patch-of-drawn-shape]
  )
end

to set-patches-to-be-affected-by-current-drawn-square-configuration
  let square-size size-of-square-drawn-by-brush
  let side-length (square-size * 2) + 1
  set patches-affected-by-drawn-shape (patch-set
    n-values side-length [right-side-ycor-delta-from-top -> [patch-at (square-size) (square-size - right-side-ycor-delta-from-top)] of center-patch-of-drawn-shape]
    n-values side-length [left-side-ycor-delta-from-top -> [patch-at (-1 * square-size) (square-size - left-side-ycor-delta-from-top)] of center-patch-of-drawn-shape]
    n-values side-length [top-side-xcor-delta-from-left -> [patch-at ((-1 * square-size) + top-side-xcor-delta-from-left) (square-size)] of center-patch-of-drawn-shape]
    n-values side-length [bottom-side-xcor-delta-from-left -> [patch-at ((-1 * square-size) + bottom-side-xcor-delta-from-left) (-1 * square-size)] of center-patch-of-drawn-shape]
  )
end

to set-patches-to-be-affected-by-current-drawn-circle-configuration
  let radius radius-of-circle-drawn-by-brush
  set patches-affected-by-drawn-shape patches with [(distance center-patch-of-drawn-shape > radius - 0.5) and (distance center-patch-of-drawn-shape < radius + 0.5)]
end

to-report is-shape-being-configured
  report has-center-of-drawn-shape-been-set-inside-world
end

to-report has-center-of-drawn-shape-been-set-inside-world
  report center-patch-of-drawn-shape != nobody
end

to-report is-brush-pressed-down
  report current-mouse-down? and (not mouse-down?-when-brush-was-last-activated)
end

to draw-with-free-form-brush
  ifelse brush-is-held-down [
    on-brush-is-held-down
    if is-brush-drawing-on-patches-not-drawn-on-since-brush-was-held-down [
      on-brush-drawing-only-once-per-patch]]
  [
    if brush-has-been-clicked [
      on-brush-has-been-clicked]
  ]
end

to-report brush-has-been-clicked
  report (not brush-is-held-down) and (brush-was-held-down-last-time-brush-was-activated)
end

to-report brush-was-held-down-last-time-brush-was-activated
  report mouse-down?-when-brush-was-last-activated
end

to-report patches-under-brush
  report patches-affected-by-brush-shape-used-at-patch patch-under-brush
end

to-report patches-affected-by-brush-shape-used-at-patch [-patch]
  (ifelse
    brush-shape = "circle" [report patches-affected-by-a-circle-shaped-brush-at-patch -patch]
    brush-shape = "square" [report patches-affected-by-a-square-shaped-brush-at-patch -patch ] )
end

to-report patches-affected-by-a-circle-shaped-brush-at-patch [-patch]
  report [patches in-radius (brush-size / 2)] of -patch
end

to-report patches-affected-by-a-square-shaped-brush-at-patch [-patch]
  report (patch-set n-values (brush-size ^ 2) [i -> patch (([pxcor] of -patch - (brush-size / 2) + 0.5) + i mod brush-size) (([pycor] of -patch - (brush-size / 2) + 0.5) + int(i / brush-size))])
end

to-report patches-brush-is-drawing-on
    report patch-set [patches-affected-by-brush-shape-used-at-patch self] of patches-brush-moved-over-while-being-held-down
end

to-report patches-brush-moved-over-while-being-held-down
    ;report patches-line-intersects coordinates-of-brush-when-last-held-down mouse-coordinates
  report patches-line-intersects item 0 coordinates-of-brush-when-last-held-down item 1 coordinates-of-brush-when-last-held-down item 0 mouse-coordinates item 1 mouse-coordinates
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

to set-brush-style-as-free-form
  set brush-style "free-form"
  on-user-set-brush-style-to-free-form
end

to set-brush-style-as-shape
  set brush-style "shape"
  on-user-set-brush-style-to-shape
end

to set-brush-shape [-brush-shape]
  set brush-shape -brush-shape
end

to set-shape-drawn-by-brush [-shape]
  set shape-drawn-by-brush -shape
end

to set-brush-type [-brush-type]
  set brush-type -brush-type
  on-brush-type-set
end

to on-brush-type-set
  update-brush-type-icon
end

to on-user-set-brush-style-to-shape
  ;set-brush-cursor-icon-to-draw
  update-brush-cursor-icon
  update-brush-draw-erase-icon
end

to on-user-set-brush-style-to-free-form
  update-brush-draw-erase-icon
  update-brush-cursor-icon
end

to-report brush-type-already-chosen [-brush-type]
  report brush-type = -brush-type
end

to toggle-add-erase
  set brush-in-draw-mode ifelse-value brush-in-draw-mode = true [false] [true]
end

to display-brush-border-outline
  ifelse show-brush-border? [
    show-brush-border-outline
    set-brush-border-outline-coordinates
    set-brush-border-outline-shape
    set-brush-border-outline-color
    set-brush-border-outline-size
    set-brush-border-outline-label ]
  [
    hide-brush-border-outline ]
end

to-report show-brush-border?
  report (brush-style = "free-form" and current-mouse-inside?)
end

to display-brush-cursor
  ifelse current-mouse-inside? [
    show-brush-cursor
    set-brush-cursor-coordinates ]
  [
    hide-brush-cursor ]
end

to update-brush-type-icon
  update-brush-type-icon-shape
  update-brush-type-icon-color
end

to update-brush-type-icon-shape
  carefully [
    ask brush-type-icon [set shape word "brush-type-icon-" brush-type] ]
  [
    ask brush-type-icon [set shape "full-square"]
  ]
end

to update-brush-type-icon-color
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

to-report is-brush-in-draw-mode
  report (brush-in-draw-mode = true)
end

to-report is-brush-in-erase-mode
  report not is-brush-in-draw-mode
end

to-report add-transparency [-color transparency-normalized]
  report lput (transparency-normalized * 255) extract-rgb -color
end

to hide-brush-cursor
  ask -brush-cursor [hide-turtle]
end

to show-brush-cursor
  ask -brush-cursor [show-turtle]
end

to set-brush-cursor-coordinates
  (ifelse
    brush-style = "free-form" [
      carefully [ ask -brush-cursor [set xcor (item 0 current-mousexy + 1.5)] ] []
      carefully [ ask -brush-cursor [set ycor (item 1 current-mousexy + 1.5)] ] [] ]
    brush-style = "shape" [
      carefully [ ask -brush-cursor [set xcor ([pxcor] of patch-under-brush)]] []
      carefully [ ask -brush-cursor [set ycor ([pycor] of patch-under-brush)]] [] ] )
  ;carefully [ ask -brush-cursor [set xcor ([pxcor] of patch-under-brush + 1.5)] ] []
  ;carefully [ ask -brush-cursor [set ycor ([pycor] of patch-under-brush + 1.5)] ] []
end

to display-brush-gfx
  display-brush-border-outline
  display-brush-cursor
  diplay-brush-xy-as-label-on-brush-mode-icon
  make-sure-brush-gets-updated-in-display-atleast-every 0.04
end

to make-sure-brush-gets-updated-in-display-atleast-every [seconds]
  if brush-activated-after-model-was-advanced [ every seconds [display] ]
  ;update-display-every-given-time-interval-if-ticks-have-not-advanced-since-brush-was-last-activated seconds
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
  (ifelse
    brush-shape = "square" [ ;offset brush for even sizes since patch under brush can not be center
      carefully [
        ask -brush-border-outline [setxy ([pxcor] of -patch-under-brush + 0.5 * ((brush-size + 1) mod 2)) ([pycor] of -patch-under-brush + 0.5 * ((brush-size + 1) mod 2))]] [] ]
    brush-shape = "circle" [ask -brush-border-outline [setxy [pxcor] of -patch-under-brush [pycor] of -patch-under-brush]])
end

to hide-brush-border-outline
  ask -brush-border-outline [hide-turtle]
end

to show-brush-border-outline
  ask -brush-border-outline [show-turtle]
end

to set-brush-border-outline-shape
  (ifelse
    brush-shape = "square" [ask -brush-border-outline [set shape "square outline thick"] ]
    brush-shape = "circle" [ask -brush-border-outline [set shape "circle outline"] ])
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
  if is-brush-pressed-down [set mouse-xy-when-brush-was-pressed-down current-mousexy]
end

to keep-track-of-current-brush-state
  update-which-patches-have-been-affected-by-brush-since-it-was-held-down
  set mouse-down?-when-brush-was-last-activated current-mouse-down?
  set mousexy-when-brush-was-last-activated current-mousexy
  set brush-activated-after-model-was-advanced true
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

to-report is-brush-drawing-on-patches-not-drawn-on-since-brush-was-held-down
  report any? newly-drawn-on-patches-brush-is-drawing-on
end

to-report get-patches-drawn-on-since-brush-was-held-down
  report patches-drawn-on-since-brush-was-held-down
end

to user-set-brush-to-draw
  set brush-in-draw-mode true
  on-user-set-brush-to-draw
end

to user-set-brush-to-erase
  set brush-in-draw-mode false
  on-user-set-brush-to-erase
end

to on-user-set-brush-to-draw
  ;set-brush-draw-erase-icon-to-draw
  update-brush-draw-erase-icon
  set-brush-cursor-icon-to-draw
end

to on-user-set-brush-to-erase
  ;set-brush-draw-erase-icon-to-erase
  update-brush-draw-erase-icon
  set-brush-icon-to-erase
end

to update-brush-draw-erase-icon
  (ifelse
    brush-style = "shape" [set-brush-draw-erase-icon-as-current-shape-drawn-by-brush ]
    brush-style = "free-form" [set-brush-draw-erase-icon-for-free-form-brush ])
end

to set-brush-draw-erase-icon-as-current-shape-drawn-by-brush
  ask brush-draw-erase-mode-icon [set shape (word "brush-mode-icon-" shape-drawn-by-brush)]
end

to set-brush-draw-erase-icon-for-free-form-brush
  ifelse is-brush-in-draw-mode [set-brush-draw-erase-icon-to-draw] [set-brush-draw-erase-icon-to-erase]
end

to set-brush-cursor-icon-to-draw
  ask -brush-cursor [set shape "brush-cursor-draw6" set size 3]
end

to set-brush-icon-to-erase
  ask -brush-cursor [set shape "brush-cursor-erase" set size 3]
end

to set-brush-cursor-icon-to-shape-configure
  ask -brush-cursor [set shape "brush-cursor-shape" set size 4]
end

to update-brush-cursor-icon
  (ifelse
    brush-style = "shape" [set-brush-cursor-icon-to-shape-configure ]
    is-brush-in-draw-mode [set-brush-cursor-icon-to-draw ]
    [set-brush-icon-to-erase ] )
end

to set-brush-draw-erase-icon-to-draw
  ask brush-draw-erase-mode-icon [set shape "brush-mode-icon-draw2"]
end

to set-brush-draw-erase-icon-to-erase
  ask brush-draw-erase-mode-icon [set shape "brush-mode-icon-erase"]
end

;==== Brush functions unique to this model ======

to draw-shape-configured-by-brush
  if brush-type = "wall" [draw-shape-with-wall]
end

to draw-shape-with-wall
  create-wall-in-patches patches-affected-by-drawn-shape
end

to on-brush-is-held-down
  (ifelse
    brush-type = "ball" [on-brush-held-down-with-ball ]
    brush-type = "halo" [on-brush-held-down-with-halo ]
    brush-type = "trace" [on-brush-held-down-with-trace ]
    brush-type = "field" [on-brush-held-down-with-field] )
end

to on-brush-drawing-only-once-per-patch
  (ifelse
    brush-type = "wall" [on-brush-used-with-wall ]
    brush-type = "counter" [on-brush-used-with-counter ] )
end

to on-brush-has-been-clicked
  (ifelse
    brush-type = "ball" [on-brush-clicked-with-ball ]
    brush-type = "field" [on-brush-clicked-with-field ] )
  log-free-form-brush-used
end





to log-free-form-brush-used
  log-output (word ifelse-value is-brush-in-draw-mode ["paint-"] ["erase-"] brush-type)
end

to log-shape-drawn
  log-output (word "place-" shape-drawn-by-brush)
end

to on-brush-clicked-with-field
  ifelse is-brush-in-draw-mode [finalize-field-configuration-with-brush] [erase-field-number-under-brush]
end

to erase-field-number-under-brush
  if [has-field] of patch-under-brush [erase-field [field-number] of patch-under-brush]
end

to on-brush-held-down-with-field
  if is-brush-in-draw-mode [create-field-with-brush]
end

to create-field-with-brush
  ifelse is-brush-currently-configuring-a-field [
    configure-current-field-with-brush ]
  [
    configure-new-field-with-brush
  ]
end

to-report is-brush-currently-configuring-a-field
  report first-patch-brush-configured-field-on != nobody
end

to configure-new-field-with-brush
  if not [has-wall] of patch-under-brush [
    set field-count field-count + 1
    set first-patch-brush-configured-field-on patch-under-brush
  ]
end

to configure-current-field-with-brush
  let field-x-value 0
  let field-y-value 0
  let prev-mouse-xcor item 0 mousexy-when-brush-was-last-activated
  let prev-mouse-ycor item 1 mousexy-when-brush-was-last-activated

  if not [has-wall] of patch-under-brush [
    set field-x-value (mouse-xcor - prev-mouse-xcor)
    set field-y-value (mouse-ycor - prev-mouse-ycor)
    if (field-x-value != 0 or field-y-value != 0 ) [ ; mouse moved from prev location
      ask patch-under-brush [
        ;output-print (word   field-x-value " " field-y-value " " patch-under-brush)
        set pcolor field-color
        set field-number field-count
        set isPainted  TRUE
        set field-x field-x-value  / (sqrt ((field-x-value ^ 2) + (field-y-value ^ 2)))
        set field-y field-y-value  / (sqrt ((field-x-value ^ 2) + (field-y-value ^ 2)))
        paint-arrow patch-under-brush
      ]
      ;paint-arrow this-patch
      set prev-mouse-xcor mouse-xcor
      set prev-mouse-ycor mouse-ycor
    ]
  ]
end

to finalize-field-configuration-with-brush
  if is-brush-currently-configuring-a-field [
    set first-patch-brush-configured-field-on nobody
    fill-field
    if (prev-command-name != "paint-field") [log-output "paint-field"]
  ]
end

to-report balls-in-patches [-patches]
  report (turtle-set [balls-here] of patches-brush-is-drawing-on)
end

to-report balls-in-patches-brush-is-drawing-on
  report balls-in-patches patches-brush-is-drawing-on
end

to on-brush-used-with-counter
  if is-brush-pressed-down [
    set-counter-number-to-be-drawn-with-brush ]
  ifelse is-brush-in-draw-mode [create-counters-in-patches patches-brush-is-drawing-on] [remove-counters-from-patches patches-brush-is-drawing-on]
end

to remove-counters-from-patches [-patches]
  ask -patches [remove-counter-from-patch]
end

to create-counters-in-patches [-patches]
  ask -patches [create-counter-in-patch]
end

;patch procedure
to remove-counter-from-patch
  if has-counter [
    let counter-number-removed counter-number-here
    ask counters-here [die]
    on-counter-removed-from-patch counter-number-removed
  ]
end

to on-counter-removed-from-patch [counter-number-removed]
  update-position-of-counter-information counter-number-removed
end

to-report can-create-counter-in-patch
  report (not has-wall) and (not has-counter)
end

;patch procedure
to create-counter-in-patch
  if can-create-counter-in-patch [
    sprout-counters 1 [
      set shape  "square"
      set size counter-width
      ;set color counter-color
      ;let hsb-color extract-hsb item counter-number-drawn-by-brush base-colors
      ;set hsb-color replace-item 1 hsb-color 100
      ;set hsb-color replace-item 2 hsb-color 100
      set color (item ((counter-number-drawn-by-brush - 1) mod length default-colors-for-ball-populations) default-colors-for-ball-populations) + 2
      set counter-number counter-number-drawn-by-brush
    ]
    on-counter-added-to-patch
  ]
end

;patch procedure
to-report counter-number-here
  report [counter-number] of one-of counters-here
end

to-report create-initialized-counter-information-gfx-overlay [-counter-number]
  let new-counter-information-gfx-overlay nobody
  let new-gfx-overlays n-values 3 [sprout-initialized-gfx-overlay]
  sprout-counter-information-gfx 1 [
    set new-counter-information-gfx-overlay self
    hide-turtle
    set shape "empty"
    set counter-number-gfx-overlay item 0 new-gfx-overlays
    ask counter-number-gfx-overlay [set label word "Area: " -counter-number]
    set ball-count-gfx-overlay item 1 new-gfx-overlays
  ]
  report new-counter-information-gfx-overlay
end

to-report ball-count-in-counter [-counter-number]
  report item (-counter-number - 1) ball-count-in-counters
end

to update-ball-count-in-counter [-counter-number]
  ask get-counter-information -counter-number [
    ask ball-count-gfx-overlay [set label (word "Count: " ball-count-in-counter -counter-number)]
  ]
end

; patch procedure
to-report sprout-initialized-gfx-overlay
  let gfx-overlay-created nobody
  sprout-gfx-overlay 1 [set gfx-overlay-created self hide-turtle set shape "empty"]
  report gfx-overlay-created
end

to increase-counter [-counter-number]
  set ball-count-in-counters replace-item (-counter-number - 1) ball-count-in-counters ((ball-count-in-counter -counter-number) + 1)
  update-ball-count-in-counter -counter-number
end

to initialize-counter-information-if-not-initialized-yet [-counter-number]
  if -counter-number > length counters-information-gfx-overlay [
    set counters-information-gfx-overlay lput create-initialized-counter-information-gfx-overlay -counter-number counters-information-gfx-overlay
    set ball-count-in-counters lput 0 ball-count-in-counters
    update-ball-count-in-counter -counter-number
  ]
end

;patch procedure
to on-counter-added-to-patch
  initialize-counter-information-if-not-initialized-yet counter-number-here
  update-position-of-counter-information counter-number-here
end

to-report counters-of [-counter-number]
  report counters with [counter-number = -counter-number]
end

to-report counters-with-counter-number-exist [-counter-number]
  report any? counters-of -counter-number
end

to-report get-counter-information [-counter-number]
  report item (-counter-number - 1) counters-information-gfx-overlay
end

to hide-counter-information [-counter-number]
  ask get-counter-information -counter-number [
    ask counter-number-gfx-overlay [hide-turtle]
    ask ball-count-gfx-overlay [hide-turtle]
  ]
end

to-report center-turtle [-turtles]
  let mean-xcor mean [xcor] of -turtles
  let mean-ycor mean [ycor] of -turtles
  report min-one-of -turtles [distancexy mean-xcor mean-ycor]
end

to set-counter-information-in-center [-counter-number]
  let center-counter center-turtle counters-of -counter-number
  let center-counter-xcor [xcor] of center-counter
  let center-counter-ycor [ycor] of center-counter
  ask get-counter-information -counter-number [
    carefully [
      ask counter-number-gfx-overlay [setxy center-counter-xcor center-counter-ycor show-turtle]
      ask ball-count-gfx-overlay [setxy center-counter-xcor (center-counter-ycor - 1) show-turtle]
    ][]
  ]
end

to update-position-of-counter-information [-counter-number]
  ifelse not counters-with-counter-number-exist -counter-number [
    hide-counter-information -counter-number]
  [
    set-counter-information-in-center -counter-number
  ]
end

;patch procedure
to-report has-counter
  report count counters-here > 0
end

to-report counter-number-of-closest-neighbor-of-patches-brush-is-drawing-on-to-mouse-xy
  report 0
end

to-report highest-counter-number-in-use
  report max [counter-number] of counters
end

to-report new-counter-number
  ifelse length ball-count-in-counters > 0 [
    report length ball-count-in-counters + 1 ]
  [
    report 1
  ]
end

to-report one-of-patches-brush-is-drawing-on-has-a-counter
  report count patches-brush-is-drawing-on with [has-counter] > 0
end

to-report counter-number-in-patch-brush-is-drawing-on-closest-to-mouse-xy
  report [counter-number-here] of min-one-of patches-brush-is-drawing-on with [has-counter] [distancexy item 0 current-mousexy item 1 current-mousexy]
end

to set-counter-number-to-be-drawn-with-brush
  ifelse one-of-patches-brush-is-drawing-on-has-a-counter [
    set counter-number-drawn-by-brush counter-number-in-patch-brush-is-drawing-on-closest-to-mouse-xy]
  [
    set counter-number-drawn-by-brush new-counter-number
  ]
end

to on-brush-held-down-with-trace
  ifelse is-brush-in-draw-mode [trace balls-in-patches-brush-is-drawing-on] [stop-tracing balls-in-patches-brush-is-drawing-on]
end

to on-brush-held-down-with-halo
  ifelse is-brush-in-draw-mode [add-halo-to-balls balls-in-patches-brush-is-drawing-on] [remove-halo-from-balls balls-in-patches-brush-is-drawing-on]
end

to on-brush-clicked-with-ball
  if is-brush-in-draw-mode [create-balls-of-population-selected-in-ui]
end

to on-brush-held-down-with-ball
  if is-brush-in-erase-mode [remove-balls-from-patches-brush-is-drawing-on]
end

to remove-balls-from-patches-brush-is-drawing-on
  ask balls-in-patches-brush-is-drawing-on [remove-ball]
end

to create-balls-of-population-selected-in-ui
  if is-a-population-selected-in-ui [
    ;update-interactively-ball-population-property-settings
    create-balls-if-under-maximum-capacity population-to-set-properties-for-in-ui number-of-balls-to-add mouse-xcor mouse-ycor
  ]
end

to on-brush-used-with-wall
  ifelse is-brush-in-draw-mode [create-wall-in-patches patches-brush-is-drawing-on] [remove-wall-from-patches patches-brush-is-drawing-on]
end

to on-wall-brush-button-clicked
  if is-first-time-radio-button-is-pressed-down "wall" [
    set-brush-type "wall"
    set-brush-style-as-free-form ]
  if should-release-brush-radio-button? "wall" [stop]
  activate-brush
end

to on-field-brush-button-clicked
  if is-first-time-radio-button-is-pressed-down "field" [
    set-brush-type "field"
    set-brush-style-as-free-form
  ]
  if should-release-brush-radio-button? "field" [stop]
  activate-brush
end

to on-counter-brush-button-clicked
  if is-first-time-radio-button-is-pressed-down "counter" [
    set-brush-type "counter"
    set-brush-style-as-free-form
  ]
  if should-release-brush-radio-button? "counter" [stop]
  activate-brush
end

to on-trace-brush-button-clicked
  if should-release-brush-radio-button? "trace" [stop]
  set-brush-type "trace"
  set-brush-style-as-free-form
  activate-brush
end

to on-halo-brush-button-clicked
  if should-release-brush-radio-button? "halo" [stop]
  set-brush-type "halo"
  set-brush-style-as-free-form
  activate-brush
end

to on-ball-brush-button-clicked
  if should-release-brush-radio-button? "ball" [stop]
  set-brush-type "ball"
  set-brush-style-as-free-form
  activate-brush
end

to on-wall-line-brush-button-clicked
  if should-release-brush-radio-button? "wall-line" [stop]
  set-brush-type "wall"
  set-shape-drawn-by-brush "line"
  set-brush-style-as-shape
  activate-brush
end

to on-wall-rectangle-brush-button-clicked
  if should-release-brush-radio-button? "wall-rectangle" [stop]
  set-brush-type "wall"
  set-shape-drawn-by-brush "rectangle"
  set-brush-style-as-shape
  activate-brush
end

to on-wall-circle-brush-button-clicked
  if should-release-brush-radio-button? "wall-circle" [stop]
  set-brush-type "wall"
  set-shape-drawn-by-brush "circle"
  set-brush-style-as-shape
  activate-brush
end

to on-wall-square-brush-button-clicked
  if is-first-time-radio-button-is-pressed-down "wall-square" [
    set-brush-type "wall"
    set-shape-drawn-by-brush "square"
    set-brush-style-as-shape
  ]
  if should-release-brush-radio-button? "wall-square" [stop]
  activate-brush
end


;=========================

to create-wall-in-patches [-patches]
  foreach sort-patches-by-proximity-to-their-most-center-patch -patches [-patch -> ask -patch [create-wall-in-patch]]
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

;patch-procedure
to-report sum-distances-to-patches [-patches]
  let patch-to-calculate-distance-from self
  report sum [distance-between-patches patch-to-calculate-distance-from self] of -patches
end

to remove-wall-from-patches [-patches]
  ask -patches [remove-wall-in-patch]
end

;ball procedure
to-report has-halo
  report get-halo != nobody
end

;ball procedure
to-report get-halo
  let retreived-halo nobody
  let links-to-halos my-links with [is-halo? other-end]
  if any? links-to-halos [set retreived-halo [other-end] of one-of links-to-halos]
  report retreived-halo
end

;ball procedure
to remove-halo
  ask turtle-set ([other-end] of my-links with [is-halo? other-end]) [die]
end

;ball procedure
to remove-ball
  remove-halo
  die
end

to remove-halo-from-balls [-balls]
  ask -balls with [has-halo] [remove-halo]
end

to add-halo-to-balls [-balls]
  ask -balls with [not has-halo] [make-halo]
end

;turtle procedure
to trace [-turtles]
  ask -turtles [pen-down]
end

;turtle procedure
to stop-tracing [-turtles]
  ask -turtles [pen-up]
end

to-report patch-at-point [point]
  report patch first point last point
end

;===== INTERSECTION MATH ==================

to-report patches-line-intersects [x1 y1 x2 y2]
  let -start patch x1 y1
  let -stop patch x2 y2
  let neighbors-stop [neighbors] of -stop
  let result (patch-set -start)
  if -start != -stop [
    let -heading heading-between-points x1 y1 x2 y2
    let current-patch -start
    while [current-patch != -stop and not member? current-patch neighbors-stop] [
      set current-patch min-one-of ([neighbors with [not member? self result]] of current-patch)
      [abs (-heading - (heading-between-points x1 y1 pxcor pycor))]
      set result (patch-set result current-patch)
    ]
  ]
  report (patch-set result -stop)
end

to-report heading-between-points [x1 y1 x2 y2]
  report ((90 - atan (y2 - y1) (x2 - x1) ) mod 360)
end
@#$#@#$#@
GRAPHICS-WINDOW
201
10
714
524
-1
-1
9.53
1
11
1
1
1
0
0
0
1
-26
26
-26
26
1
1
1
ticks
30.0

SLIDER
800
273
939
306
number-of-balls-to-add
number-of-balls-to-add
1
100
10.0
1
1
NIL
HORIZONTAL

BUTTON
32
10
149
56
start a new task
start-new-task\n
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
422
539
513
572
play
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

BUTTON
101
61
181
121
paint-world
paint-world
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
6
120
192
142
-------------------------------------
14
0.0
1

BUTTON
942
273
1002
306
Erase All
erase-all-balls-of-population-selected-in-ui
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
267
539
364
572
save model 
save-existing-layout
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
568
539
663
572
load model
load-existing-layout
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
726
85
851
118
Color-Speed
Color-Speed
1
1
-1000

INPUTBOX
0
61
97
121
background-color
0.0
1
0
Color

MONITOR
887
220
950
265
Amount
count balls with [population-num = population-to-set-properties-for-in-ui]
17
1
11

BUTTON
26
167
91
200
Draw
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
98
167
168
200
Erase
user-set-brush-to-erase\nset-brush-style-as-free-form
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
26
208
168
241
brush-size
brush-size
1
10
1.0
1
1
NIL
HORIZONTAL

BUTTON
26
247
94
280
Circle
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

BUTTON
102
247
170
280
Square
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
7
317
95
350
Wall
on-wall-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
6
506
95
539
Circle
on-wall-circle-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
100
506
189
539
Square
on-wall-square-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
6
357
95
390
Counter
on-counter-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
100
318
191
351
Field
on-field-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
722
273
796
306
Add Balls
on-ball-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
6
397
95
430
Halo
on-halo-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
100
356
189
389
Trace
on-trace-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
75
143
126
177
Brush
14
0.0
1

TEXTBOX
53
293
151
311
Brush Pallete
14
0.0
1

TEXTBOX
788
177
865
195
Ball Pallete
14
0.0
1

BUTTON
6
468
95
501
Line
on-wall-line-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
100
468
189
501
Rectangle
on-wall-rectangle-brush-button-clicked
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
56
444
135
462
Wall Shape
14
0.0
1

INPUTBOX
53
549
131
609
wall-color
105.0
1
0
Color

SWITCH
726
46
886
79
flash-wall-collision
flash-wall-collision
0
1
-1000

MONITOR
803
220
876
265
Population
population-to-set-properties-for-in-ui
17
1
11

BUTTON
723
220
790
265
Next
select-next-population-in-properties-ui
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
795
19
822
37
SFX
14
0.0
1

TEXTBOX
750
201
897
220
Select population to add balls
11
0.0
1

SWITCH
725
489
830
522
log-enabled
log-enabled
1
1
-1000

MONITOR
728
375
800
420
Population 1
item 0 wall-collision-count
17
1
11

TEXTBOX
766
346
900
371
Wall Collisions
14
0.0
1

MONITOR
807
375
882
420
Population 2
item 1 wall-collision-count
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

battery
false
9
Rectangle -7500403 true false 14 90 284 210
Rectangle -2674135 true false 255 90 285 210
Rectangle -2674135 true false 30 90 30 210
Rectangle -16777216 true false 15 90 45 210
Rectangle -13791810 false true 164 151 195 147
Rectangle -1 true false 25 137 31 161
Rectangle -1 true false 259 141 280 148
Rectangle -1 true false 18 146 40 153

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

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

brush-cursor-shape
false
0
Circle -13840069 true false 116 116 67
Rectangle -13840069 true false 138 143 243 158
Rectangle -13840069 true false 46 143 151 158
Rectangle -13840069 true false 142 43 157 148
Rectangle -13840069 true false 143 146 158 251
Circle -16777216 true false 128 128 44

brush-cursor-shape3
false
0
Rectangle -13840069 true false 125 126 132 176
Rectangle -13840069 true false 125 169 177 176
Rectangle -13840069 true false 170 125 178 176
Rectangle -13840069 true false 125 125 177 132
Rectangle -13840069 true false 171 146 220 154
Rectangle -13840069 true false 82 146 131 154
Rectangle -13840069 true false 147 80 155 129
Rectangle -13840069 true false 147 170 155 219

brush-mode-icon-circle
false
7
Rectangle -7500403 true false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Circle -13791810 true false 23 26 254
Circle -7500403 true false 45 49 210
Rectangle -16777216 false false 0 0 300 300

brush-mode-icon-draw-circle
false
7
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Circle -13345367 true false -2 -2 302
Circle -7500403 true false 30 30 240
Polygon -1184463 true false 210 30 240 30 270 60 270 90 90 255 90 225 60 195 60 195 30 195 210 30
Polygon -16777216 false false 30 195 210 30 240 30 270 60 270 90 90 255 90 225 60 195 30 195
Line -16777216 false 240 30 60 195
Line -16777216 false 270 60 90 225
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 30 195 15 270 90 255 90 225 60 195 30 195
Polygon -16777216 false false 30 195 15 270 90 255 90 225 60 195 30 195

brush-mode-icon-draw-circle3
false
5
Rectangle -7500403 true false 0 0 300 300
Circle -13345367 true false 23 23 255
Circle -7500403 true false 45 45 210
Rectangle -16777216 false false 0 0 300 300

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

brush-mode-icon-line
false
7
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Polygon -13791810 true false 46 246 241 36 256 51 61 261 46 246

brush-mode-icon-rectangle
false
7
Rectangle -7500403 true false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Rectangle -13791810 true false 23 80 278 230
Rectangle -7500403 true false 42 100 259 209
Rectangle -16777216 false false 0 0 300 300

brush-mode-icon-square
false
7
Rectangle -7500403 true false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Rectangle -13791810 true false 40 41 268 268
Rectangle -7500403 true false 68 70 239 241
Rectangle -16777216 false false 0 0 300 300

brush-type-icon-ball
false
9
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Circle -16777216 true false 93 89 118
Circle -955883 true false 94 90 116

brush-type-icon-ball2
false
15
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Circle -1184463 false false 41 42 220
Circle -11221820 true false 124 19 50
Circle -955883 true false 92 88 120
Circle -11221820 true false 40 187 50
Circle -11221820 true false 213 186 50

brush-type-icon-counter
false
7
Rectangle -7500403 true false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Line -16777216 false 60 0 60 300
Line -16777216 false 240 0 240 315
Line -16777216 false 0 60 315 60
Line -16777216 false 0 240 300 240
Rectangle -13840069 true false 139 152 159 219
Rectangle -13840069 true false 124 219 174 235
Polygon -13840069 true false 159 137 125 162 125 184 159 163
Rectangle -13840069 true false 65 190 116 205
Rectangle -13840069 true false 83 173 98 223
Circle -16777216 true false 147 52 85
Circle -955883 true false 148 53 83
Line -16777216 false 172 33 154 18
Line -16777216 false 136 45 105 20
Line -16777216 false 122 83 107 73

brush-type-icon-field
false
7
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Polygon -13345367 true false 60 195 180 195 180 150 256 216 180 285 180 240 180 240 60 240 60 195
Line -16777216 false 45 60 75 60
Line -16777216 false 90 60 135 60
Line -16777216 false 135 60 150 60
Circle -955883 true false 158 42 94
Line -16777216 false 135 90 120 90
Line -16777216 false 147 120 105 120
Line -16777216 false 90 120 60 120
Line -16777216 false 60 90 30 90
Line -16777216 false 105 90 60 90
Line -16777216 false 50 120 40 120

brush-type-icon-halo
false
9
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Circle -16777216 true false 93 89 118
Circle -955883 true false 94 90 116
Circle -1184463 false false 33 33 234

brush-type-icon-halo2
false
9
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Circle -16777216 true false 88 84 128
Circle -955883 true false 89 85 126
Circle -1184463 false false 32 31 238

brush-type-icon-trace
false
9
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Polygon -13840069 true false 150 165 191 253 228 209 255 270 245 275 270 285 272 258 262 264 232 194 193 237 157 160
Circle -16777216 true false 87 83 110
Circle -955883 true false 88 84 108

brush-type-icon-trace3
false
9
Rectangle -7500403 true false 0 0 300 300
Rectangle -16777216 false false 0 0 300 300
Polygon -2674135 true false 45 195 15 270
Polygon -2674135 true false 132 150 174 247 218 191 258 263 249 271 273 280 276 252 266 259 220 170 176 225 143 142
Circle -16777216 true false 63 58 128
Circle -955883 true false 64 59 126

brush-type-icon-wall
false
6
Rectangle -1 true false 0 0 300 300
Rectangle -13345367 true false 15 225 150 285
Rectangle -13345367 true false 165 225 300 285
Rectangle -13345367 true false 75 150 210 210
Rectangle -13345367 true false 0 150 60 210
Rectangle -13345367 true false 225 150 300 210
Rectangle -13345367 true false 166 75 301 135
Rectangle -13345367 true false 15 75 150 135
Rectangle -13345367 true false 0 0 60 60
Rectangle -13345367 true false 225 0 300 60
Rectangle -13345367 true false 75 0 210 60
Polygon -6459832 true false 123 155 207 261 221 265 234 251 235 238 147 136 123 155
Polygon -7500403 true false 140 147 155 133 149 116 150 109 154 104 168 97 190 91 179 78 154 82 127 93 101 111 88 122 92 129 93 131 91 135 87 136 83 134 78 129 59 145 57 157 78 181 88 187 109 168 104 161 103 154 105 155 105 152 105 152 112 155 116 161
Polygon -16777216 false false 178 79 188 90 152 104 149 108 149 117 155 133 147 139 130 152 115 161 111 154 104 153 102 156 108 167 88 187 78 181 56 155 59 146 76 129 85 137 89 139 92 131 88 122 129 91 156 82 176 78
Polygon -16777216 false false 150 138 234 238 234 252 220 263 206 260 125 157
Rectangle -16777216 false false 0 0 300 300

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

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

eraser
false
0
Rectangle -7500403 true true 0 0 300 360
Rectangle -7500403 true true 0 0 300 375

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

full-square
false
0
Rectangle -7500403 true true 0 0 300 300

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

magnet
true
0
Polygon -7500403 true true 120 270 75 270 60 105 60 60 75 30 106 10 150 3 195 10 225 30 240 60 240 105 225 270 180 270 195 105 196 74 184 55 165 45 135 45 115 55 104 75 105 105
Polygon -16777216 true false 219 264 188 264 193 214 224 215
Polygon -16777216 true false 81 264 112 264 107 214 76 215

minus
true
15
Line -7500403 false 165 135 135 135

orbit 1
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 false true 41 41 218

orbit 2
true
0
Circle -7500403 true true 116 221 67
Circle -7500403 true true 116 11 67
Circle -7500403 false true 44 44 212

orbit 3
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 true true 26 176 67
Circle -7500403 true true 206 176 67
Circle -7500403 false true 45 45 210

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

plus
false
15
Line -7500403 false 150 0 150 300
Line -7500403 false 300 165 0 165
Line -7500403 false 300 165 0 165
Line -7500403 false 300 165 0 165
Line -7500403 false 300 165 0 165
Line -7500403 false 150 0 150 300
Line -7500403 false 150 0 150 300

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

square-outline
false
6
Rectangle -13840069 false true 0 0 300 300

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

thin ring
true
0
Circle -7500403 false true -1 -1 301

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
