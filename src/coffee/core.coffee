React.initializeTouchEvents(true)
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;

Knob = React.createClass(
  getInitialState: ->
    return {
      loop: 0
      dot: [0,0]
    }

  findCircleAngle: (x, y) ->
    deg = Math.atan2(x - this.state.dot[0], this.state.dot[1] - y) * (180 / Math.PI)
    if deg < 0
      deg = deg + 360

    return deg

  componentDidMount: ->
    that = this
    that.click = [0,0]
    
    dot = $(React.findDOMNode(this.refs.dot))
    that.setState({ dot: [dot.offset().left, dot.offset().top] })

    control = $(React.findDOMNode(this.refs.control))
    control.on('touchstart', (e) ->
      e.preventDefault()
      pageX = e.originalEvent.changedTouches[0].pageX
      pageY = e.originalEvent.changedTouches[0].pageY 

      that.click = [pageX, pageY]
 
      $(document).on('touchmove', (e) ->
        e.preventDefault()
        x = e.originalEvent.changedTouches[0].pageX
        y = e.originalEvent.changedTouches[0].pageY

        clickDeg = that.findCircleAngle(that.click[0], that.click[1])
        moveDeg = that.findCircleAngle(x, y)
        deg = (moveDeg - clickDeg)
        that.click = [x, y]

        if Math.abs(deg) > 10
          return

        that.props.onChange({ axis: that.props.axis, deg: deg })
      )

      $(document).one('touchend touchcancel', (e) ->
        e.preventDefault()
        $(document).off('touchmove')
      )
    )
 

  render: ->
    className = 'sketch-controls-left'
    if this.props.axis == 'vertical'
      className = 'sketch-controls-right'

    style = 
      '-ms-transform': "rotate(#{this.props.pos}deg)"
      '-moz-transform': "rotate(#{this.props.pos}deg)"
      '-webkit-transform': "rotate(#{this.props.pos}deg)"
      '-o-transform': "rotate(#{this.props.pos}deg)"
   
    return(
      <div className={className} style=style ref="control">
        <div className="sketch-controls-inner">
          <div className="sketch-controls-indicator"></div>
          <div className="sketch-controls-dot" ref="dot"></div>
        </div>
      </div>
    )
)

Content = React.createClass(
  getInitialState: ->
    images = [
      'http://bit.ly/1FwzVuF'
      'http://bit.ly/1FwzVuF'
      'http://bit.ly/1FwzVuF'
      'http://bit.ly/1FwzVuF'
    ]
    rows = 0 
 
    for i in [0..images.length]
      if images.length <= i * i
        rows = i
        break

    return {
      width: 0
      height: 0
      rows: rows
      images: images
      imageReady: false
    }

  componentDidMount: ->
    that = this
    $('.sketch-intro').on('transitionend webkitTransitionEnd', (e) ->
      if e.originalEvent.propertyName == 'opacity'
        that.setState({ imageReady: true })
    )
  
    $(window).on('resize', () ->
      content = $(React.findDOMNode(that.refs.content))
      that.setState({ width: content.width(), height: content.height() })
    )
    $(window).trigger('resize')

  render: ->
    that = this

    style = 
      display: if this.state.imageReady then 'block' else 'none'
      '-ms-transform': "translate(#{this.props.pos[0]}px, #{this.props.pos[1]}px)"
      '-moz-transform': "translate(#{this.props.pos[0]}px, #{this.props.pos[1]}px)"
      '-webkit-transform': "translate(#{this.props.pos[0]}px, #{this.props.pos[1]}px)"
      '-o-transform': "translate(#{this.props.pos[0]}px, #{this.props.pos[1]}px)"

      width: (that.state.width) * that.state.rows
      height: that.state.height * that.state.rows

    images = this.state.images.map((image, i) ->
      imageStyle =
        width: that.state.width
        height : that.state.height

      return (
        <div className="sketch-image" style={imageStyle}>
          <span className="helper"/>
          <img src={image} />
        </div>
      )
    )

    return(
      <div className="sketch-content" ref="content">
        <ReactCSSTransitionGroup transitionName="sketch-intro">
          <div className="sketch-intro" key={this.props.ready} >
            <h3>To make mastering Sketch 3 more fun, this project showcases simple doodles and concepts. Time to tap into that inner child to create and shake things up!</h3>
            <br/>
            <h2 className="hidden-lg">
              Turn left knob to move horizontally and right knob to move vertically
            </h2>
            <h2 className="hidden-md hidden-sm hidden-xs">
              Press WASD or 
              <i className="fa fa-chevron-up"/>
              <i className="fa fa-chevron-down"/>
              <i className="fa fa-chevron-left"/>
              <i className="fa fa-chevron-right"/>
              to view sketch3s</h2>
          </div>
        </ReactCSSTransitionGroup>
        <div className="sketch-images" style={style} ref="sketch-images">
          {{images}}
          <div className="clearfix" />
        </div>
      </div>
    )
)

App = React.createClass(
  getInitialState: ->
    return {
      touches: {}
      keys: {}
      ready: false
      horizontalPos: 0 
      verticalPos: 0
    }

  componentDidMount: ->
    that = this

    $(document).one('keydown click touchstart', (e) ->
      e.preventDefault()
      that.enable()
    )

  handleChange: (e) ->
    this.update(e.axis, e.deg)   

  update: (axis, i) ->
    that = this

    p = 'horizontalPos'
    if axis == 'vertical'
      p = 'verticalPos'

    stateUpdate = {}
    content = that.refs.content
    contentWidth = content.state.width
    contentHeight = content.state.height

    if axis == 'horizontal'
      if that.state[p] + i > 0
        stateUpdate[p] = 0
        that.setState(stateUpdate)
        return

      if that.state[p] + i < -1 * contentWidth
        stateUpdate[p] = -1 * contentWidth
        that.setState(stateUpdate)
        return


    if axis == 'vertical'
      if that.state[p] + i > 0
        stateUpdate[p] = 0
        that.setState(stateUpdate)
        return

      if that.state[p] + i < -1 * contentHeight
        stateUpdate[p] = -1 * contentHeight
        that.setState(stateUpdate)
        return

    pos = (that.state[p] + i)
    stateUpdate[p] = pos
    that.setState(stateUpdate)

  enable: ->
    that = this 
    increment = 15 

    that.setState({ ready: true })
    $('.instructions').css('opacity', '1')

    $(document).on('keydown', (e) ->
      keys = that.state.keys
      keys[e.which] = true
      that.setState({ keys: keys })

      if keys[37] || keys[65]
        # move cursor left and turn left on left
        e.preventDefault()
        that.update('horizontal', -1 * increment)

      if keys[39] || keys[68]
        # move cursor right and turn right on left
        e.preventDefault()
        that.update('horizontal', increment)

      if keys[40] || keys[83]
        # move cursor up and turn right on right
        that.update('vertical', increment)

      if keys[38] || keys[87]
        # move cursor down and turn right on right
        e.preventDefault()
        that.update('vertical', -1 * increment)
    )

    $(document).on('keyup', (e) ->
      keys = that.state.keys
      delete keys[e.which]

      that.setState({ keys: keys })
    )

  render: ->
    pos = [this.state.horizontalPos, this.state.verticalPos]

    return(
      <div className="sketch">
        <div className="sketch-logo">
          <img src="images/logo.png"/>
        </div>
        <Content ready={this.state.ready} pos={pos} ref="content" /> 
        <div className="sketch-controls">
          <Knob axis="horizontal" pos={this.state.horizontalPos} onChange={this.handleChange} />
          <Knob axis="vertical" pos={this.state.verticalPos} onChange={this.handleChange} />
        </div>
      </div>
    )
)

React.render(                                                                      
  <App />,
  document.getElementById('app')
)  
