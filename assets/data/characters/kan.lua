local char = {}

char.name = "Kan" -- Filename if not used
char.desc = "Kan is from another world brough, earth to be specific where they were used as experiments to research cures\nafter escaping on a pod he arrives at Hartstoria and unknown to him he was implanted a M.C.H.A.F.E before escaping"
char.traits = {
    "non-obedient",
    "Slighly Inmufelaized"
}

char.parts = {
    body = {
        offset = {0, 0},
        origin = {0, 0},
        head = {
            offset = {0, -11},
            origin = {0, 2},
            face = {
                offset = {0, -14},
                origin = {0, 0}
            },
            hair = {
                offset = {1, -20},
                origin = {0, 1}
            },
            leftear = {
                offset = {10, -21},
                origin = {0, 2}
            },
            rightear = {
                offset = {-10, -20},
                origin = {0, 3}
            }
        },
        leftarm = {
            offset = {8, -2},
            origin = {-1, -2},
            leftpaw = {
                offset = {9, 4},
                origin = {0, 0}
            }
        },
        rightarm = {
            offset = {-8, -1},
            origin = {1, -2},
            rightpaw = {
                offset = {-8, 4},
                origin = {0, 0}
            }
        },
        leftleg = {
            offset = {4, 10},
            origin = {0, -2},
            leftfeet = {
                offset = {3, 19},
                origin = {0, 0}
            }
        },
        rightleg = {
            offset = {-3, 10},
            origin = {0, -2},
            rightfeet = {
                offset = {-3, 19},
                origin = {0, 0}
            }
        }
    }
}

function char:load()
    print("Character " .. char.name)
end

return char