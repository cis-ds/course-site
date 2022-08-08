library(tidyverse)
library(rcfss)
library(hexSticker)
library(here)
library(showtext)

font_add_google("Cormorant Garamond", "garamond")
showtext_auto()

p <- ggplot(data = scorecard,
            mapping = aes(x = type)) +
  geom_bar(fill = "#D6D6CE") +
  theme_void() +
  theme_transparent()

sticker(subplot = p, package = "CIS",
        h_color = "#767676", h_fill = "#800000", p_color = "#D6D6CE",
        s_x = 1,
        s_width = 1, s_height = .8,
        filename = here("static", "img", "cis.svg"))
