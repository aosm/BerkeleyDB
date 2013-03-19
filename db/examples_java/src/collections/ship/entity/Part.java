/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 2002,2008 Oracle.  All rights reserved.
 *
 * $Id: Part.java,v 12.7 2008/01/08 20:58:29 bostic Exp $
 */

package collections.ship.entity;

/**
 * A Part represents the combined key/data pair for a part entity.
 *
 * <p>In this sample, Part is created from the stored key/data entry using a
 * SerialSerialBinding.  See {@link SampleViews.PartBinding} for details.
 * Since this class is not used directly for data storage, it does not need to
 * be Serializable.</p>
 *
 * @author Mark Hayes
 */
public class Part {

    private String number;
    private String name;
    private String color;
    private Weight weight;
    private String city;

    public Part(String number, String name, String color, Weight weight,
                String city) {

        this.number = number;
        this.name = name;
        this.color = color;
        this.weight = weight;
        this.city = city;
    }

    public final String getNumber() {

        return number;
    }

    public final String getName() {

        return name;
    }

    public final String getColor() {

        return color;
    }

    public final Weight getWeight() {

        return weight;
    }

    public final String getCity() {

        return city;
    }

    public String toString() {

        return "[Part: number=" + number +
               " name=" + name +
               " color=" + color +
               " weight=" + weight +
               " city=" + city + ']';
    }
}
