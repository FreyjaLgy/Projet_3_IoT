package com.example.thing_shutter;

public class Shutter {
    private String name;
    private boolean open;

    public Shutter(String name, boolean open) {
        this.name = name;
        this.open = open;
    }

    public String getName() {
        return name;
    }

    public boolean isOpen() {
        return open;
    }

    public void setOpen(boolean open) {
        this.open = open;
    }
}
