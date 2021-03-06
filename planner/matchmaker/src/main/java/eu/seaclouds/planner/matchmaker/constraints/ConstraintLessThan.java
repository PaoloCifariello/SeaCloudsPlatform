/**
 * Copyright 2014 SeaClouds
 * Contact: SeaClouds
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
package eu.seaclouds.planner.matchmaker.constraints;

import eu.seaclouds.planner.matchmaker.Pair;
import eu.seaclouds.planner.matchmaker.PropertyValue;

public class ConstraintLessThan<T extends Comparable<T>> extends Constraint {

    public ConstraintLessThan(String name, T value) {
        super(name, ConstraintTypes.LessThan, value);
    }

    public boolean checkConstraint(PropertyValue prop) {
        String pvalstr = ((T) prop.getValue()).toString();
        boolean v = new Version(value.toString()).compareTo(new Version(pvalstr)) > 0;
        return super.checkConstraint(prop) && v;
    }
}
