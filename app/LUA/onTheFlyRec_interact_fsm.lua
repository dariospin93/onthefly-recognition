
event_table = {
    See         = "e_exit",
    This        = "e_train",
    What        = "e_recog",
    Forget      = "e_forget",
}

interact_fsm = rfsm.state{

    ----------------------------------
    -- state SUB_MENU               --
    ----------------------------------
    SUB_MENU = rfsm.state{
        entry=function()
            print("in substate MENU : waiting for speech command!")
        end,

        doo = function()
            while true do
                -- speak(ispeak_port, "What should I do?")
                result = SM_Reco_Grammar(speechRecog_port, grammar)
                print("received REPLY: ", result:toString() )
                local cmd = result:get(1):asString()
                rfsm.send_events(fsm, event_table[cmd])
                rfsm.yield(true)
            end
        end
    },

    ----------------------------------
    -- states                       --
    ----------------------------------

    SUB_EXIT = rfsm.state{
        entry=function()
            speak(ispeak_port, "Ok, bye bye")
            rfsm.send_events(fsm, 'e_menu_done')
        end
    },

    SUB_TRAIN = rfsm.state{
        entry=function()
            local obj = result:get(7):asString()
            print ("object is ", obj)
            local b = onTheFlyRec_train(onTheFlyRec_port, obj)
        end
    },

    SUB_RECOG = rfsm.state{
        entry=function()
            print ("in recognition mode ")
            local b = onTheFlyRec_recognize(onTheFlyRec_port)
        end
    },

    SUB_FORGET = rfsm.state{
        entry=function()
            local obj = result:get(5):asString()
            if  obj == "objects" then
                print ("forgetting all objects")
                obj="all"
                
            else
                print ("forgetting single object", obj)
            end
            local b = onTheFlyRec_forget(onTheFlyRec_port, obj)
            
        end
    },

    ----------------------------------
    -- state transitions            --
    ----------------------------------

    rfsm.trans{ src='initial', tgt='SUB_MENU'},
    rfsm.transition { src='SUB_MENU', tgt='SUB_EXIT', events={ 'e_exit' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_TRAIN', events={ 'e_train' } },
    rfsm.transition { src='SUB_TRAIN', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_RECOG', events={ 'e_recog' } },
    rfsm.transition { src='SUB_RECOG', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_FORGET', events={ 'e_forget' } },
    rfsm.transition { src='SUB_FORGET', tgt='SUB_MENU', events={ 'e_done' } },
}
