import numpy as np

from bokeh.layouts import row, column
from bokeh.models import CustomJS, Slider, Arrow, OpenHead, NormalHead
from bokeh.plotting import figure, output_file, show, ColumnDataSource

plot_v = figure(x_range=(-1000, 1000), y_range=(-1000, 1000),
                plot_width=800, plot_height=800)

# plot_v.line('x', 'y', source=dict(x=[0], y=[0]), line_width=1, line_alpha=0.0)
# plot_dv.line('x', 'y', source=dict(x=[0], y=[0]), line_width=1, line_alpha=0.0)

v1 = Arrow(end=NormalHead(line_color="red", line_width=2, size=10),
           x_start=0, y_start=0, x_end=1000, y_end=0, line_color="red")
v2 = Arrow(end=OpenHead(line_color="firebrick", line_width=2, size=10),
           x_start=0, y_start=0, x_end=1000, y_end=0, line_color = "firebrick")
dv = Arrow(end=OpenHead(line_color="green", line_width=2, size=10),
           x_start=0, y_start=0, x_end=1, y_end=0, line_color="green")
i = Arrow(end=OpenHead(line_color="blue", line_width=2, size=10),
          x_start=0, y_start=0, x_end=1, y_end=0, line_color="blue")

plot_v.add_layout(v1)
plot_v.add_layout(v2)
plot_v.add_layout(dv)
plot_v.add_layout(i)

amp_slider = Slider(start=500, end=1000, value=1000, step=10, title="Amplitude")
gemma_slider = Slider(start=0, end=np.pi/2, value=0, step=0.05, title="Gemma")
theta_slider = Slider(start=0, end=np.pi/2, value=0, step=0.05, title="Theta")


callback_v2 = CustomJS(args=dict(source=v2, amp_slider=amp_slider, gemma_slider=gemma_slider),
                       code="""
    const length = amp_slider.value;
    const gemma = -gemma_slider.value;
    source.x_end.value = length * Math.cos(gemma)
    source.y_end.value = length * Math.sin(gemma)
    source.change.emit();
""")
callback_dv = CustomJS(args=dict(source=dv, v1=v1, v2=v2),
                       code="""
    source.x_end.value = v1.x_end.value - v2.x_end.value
    source.y_end.value = v1.y_end.value - v2.y_end.value
    source.change.emit();
""")
callback_i = CustomJS(args=dict(source=i, dv=dv, theta_slider=theta_slider),
                       code="""
    const scale = 0.5
    const x = scale * dv.x_end.value
    const y = scale * dv.y_end.value
    const theta = -theta_slider.value

    console.log(theta)
    source.x_end.value = x * Math.cos(theta) - y * Math.sin(theta)
    source.y_end.value = y * Math.cos(theta) + x * Math.sin(theta)

    source.change.emit();
""")

amp_slider.js_on_change('value', callback_v2)
amp_slider.js_on_change('value', callback_dv)
amp_slider.js_on_change('value', callback_i)
gemma_slider.js_on_change('value', callback_v2)
gemma_slider.js_on_change('value', callback_dv)
gemma_slider.js_on_change('value', callback_i)
theta_slider.js_on_change('value', callback_i)

# layout = row(
#     column(plot_v, plot_dv),
#     column(amp_slider, gemma_slider, theta_slider),
# )

layout = column(plot_v, amp_slider, gemma_slider, theta_slider)

output_file("slider.html", title="slider.py example")

show(layout)
