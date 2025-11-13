package com.example.thing_shutter;

import com.example.thing_shutter.Shutter;
import org.springframework.web.bind.annotation.*;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@RestController
//@RequestMapping("/shutter")
public class ShutterController {

    private final List<Shutter> shutters = new ArrayList<>();

    public ShutterController() {
        // Exemple : 3 volets
        shutters.add(new Shutter("Salon", true));
        shutters.add(new Shutter("Cuisine", true));
        shutters.add(new Shutter("Chambre", true));
        autoCloseIfEvening();
    }

    // Renvoie la liste des volets avec leur état.
    @PostMapping("/action/getStatus")
    public List<Shutter> getStatus() {
        return shutters;
    }

    //Ouvrir tous les volets manuellement.
    @PostMapping("/action/openall")
    public void openAll() {
        shutters.forEach(s -> s.setOpen(true));
    }

    //Fermer tous les volets manuellement.
    @PostMapping("/action/closeall")
    public void closeAll() {
        shutters.forEach(s -> s.setOpen(false));
    }


    // Ouvre un volet spécifique 
    @PostMapping("/action/open/{name}")
    public String open(@PathVariable String name) {
        shutters.stream()
                .filter(s -> s.getName().equalsIgnoreCase(name))
                .findFirst()
                .ifPresent(s -> s.setOpen(true));
        return "Volet '" + name + "' ouvert.";
    }

    // Ferme un volet spécifique 
    @PostMapping("/action/close/{name}")
    public String close(@PathVariable String name) {
        shutters.stream()
                .filter(s -> s.getName().equalsIgnoreCase(name))
                .findFirst()
                .ifPresent(s -> s.setOpen(false));
        return "Volet '" + name + "' fermé.";
    }


    //** Ferme tous les volets après 19h au démarrage du service
    private void autoCloseIfEvening() {
        LocalTime now = LocalTime.now();
        if (now.isAfter(LocalTime.of(19, 0))) {
            shutters.forEach(s -> s.setOpen(false));
        }
    }

}
