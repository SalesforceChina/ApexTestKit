/**
 * Apex Test Kit
 */

@IsTest
private class ATKWandTest {
    @IsTest
    static void testDistributor_Production() {
        List<Object> leftList = new List<Object> { 'A', 'B', 'C' };
        List<Object> rightList = new List<Object> { '1', '2' };
        ATKWand.Distributor distributor = new ATKWand.Distributor();
        List<List<Object>> pairs = distributor.product(leftList, rightList, 6);
        for (Integer i = 0; i < pairs.size(); i++) {
            System.debug(String.valueOf(pairs[i][0]) + String.valueOf(pairs[i][1]));
        }
        System.assertEquals(6, pairs.size());
        System.assertEquals('A1', String.valueOf(pairs[0][0]) + String.valueOf(pairs[0][1]));
        System.assertEquals('A2', String.valueOf(pairs[1][0]) + String.valueOf(pairs[1][1]));
        System.assertEquals('B1', String.valueOf(pairs[2][0]) + String.valueOf(pairs[2][1]));
        System.assertEquals('B2', String.valueOf(pairs[3][0]) + String.valueOf(pairs[3][1]));
        System.assertEquals('C1', String.valueOf(pairs[4][0]) + String.valueOf(pairs[4][1]));
        System.assertEquals('C2', String.valueOf(pairs[5][0]) + String.valueOf(pairs[5][1]));
    }

    @IsTest
    static void testDistributor_Production2() {
        List<Object> leftList = new List<Object> { 'A', 'B', 'C' };
        List<Object> rightList = new List<Object> { '1', '2' };
        ATKWand.Distributor distributor = new ATKWand.Distributor();
        List<List<Object>> pairs = distributor.product2(leftList, rightList, 5);
        for (Integer i = 0; i < pairs.size(); i++) {
            System.debug(String.valueOf(pairs[i][0]) + String.valueOf(pairs[i][1]));
        }
        System.assertEquals(5, pairs.size());
        System.assertEquals('A1', String.valueOf(pairs[0][0]) + String.valueOf(pairs[0][1]));
        System.assertEquals('B2', String.valueOf(pairs[1][0]) + String.valueOf(pairs[1][1]));
        System.assertEquals('C1', String.valueOf(pairs[2][0]) + String.valueOf(pairs[2][1]));
        System.assertEquals('A2', String.valueOf(pairs[3][0]) + String.valueOf(pairs[3][1]));
        System.assertEquals('B1', String.valueOf(pairs[4][0]) + String.valueOf(pairs[4][1]));
    }

    @IsTest
    static void testDistributor_Distribution() {
        List<Object> leftList = new List<Object> { 'i0', 'i1', 'i2', 'i3', 'i4' };
        List<Object> rightList = new List<Object> { 'j0', 'j1' };
        ATKWand.Distributor distributor = new ATKWand.Distributor();
        List<List<Object>> pairs = distributor.distribute(leftList, rightList);
        for (Integer i = 0; i < pairs.size(); i++) {
            System.debug(String.valueOf(pairs[i][0]) + String.valueOf(pairs[i][1]));
        }
        System.assertEquals(5, pairs.size());
        System.assertEquals('i0j0', String.valueOf(pairs[0][0]) + String.valueOf(pairs[0][1]));
        System.assertEquals('i1j0', String.valueOf(pairs[1][0]) + String.valueOf(pairs[1][1]));
        System.assertEquals('i2j0', String.valueOf(pairs[2][0]) + String.valueOf(pairs[2][1]));
        System.assertEquals('i3j1', String.valueOf(pairs[3][0]) + String.valueOf(pairs[3][1]));
        System.assertEquals('i4j1', String.valueOf(pairs[4][0]) + String.valueOf(pairs[4][1]));
    }

    @IsTest
    static void testATKSpellBook() {
        ATKWizard.I().wantMany('A')
            .origin(new Map<String, Object> {
                'a1' => 'a1',
                'a2' => 'a2'
            })
            .fields(new Map<String, Object> {
                '$a1' => '$1.a1 + 1',
                '$a2' => '$1.a2 + 2'
            })
            .total(2)
            .hasMany('B')
                .referenceBy('A__c')
                .fromList(new List<SObject> { null, null, null })
                .belongsTo('D')
                    .hasMany('E')
                    .also()
            .also(2)
            .belongsTo('C')
                .referenceBy('C__c');
        
        ATKWand.ATKSpellBook spellBook = ATKWizard.I().spellBook;
        ATKWand.EntityNodeMatrix matrix = spellBook.matrix;
        
        System.assertEquals(3, matrix.entityNodeMatrix.size());

        Iterator<ATKWand.EntityNode> entityIterator = spellBook.iterator();
        while(entityIterator.hasNext()) {
            ATKWand.EntityNode entity = entityIterator.next();
            switch on entity.Name {
                when 'A' {
                    System.assertEquals(2, entity.total);
                    System.assertEquals(2, entity.fieldInitMap.keySet().size());
                    System.assert(entity.fieldInitMap.containsKey('A1'));
                    System.assertEquals(2, entity.fieldRuleMap.keySet().size());
                    System.assert(entity.fieldRuleMap.containsKey('$A1'));
                    System.assertEquals(1, entity.referenceToMap.keySet().size());
                    System.assertEquals('C', entity.referenceToMap.get('C__C').name);
                }
                when 'B' {
                    System.assertEquals(3, entity.total);
                    System.assertEquals(2, entity.referenceToMap.keySet().size());
                    System.assertEquals('A', entity.referenceToMap.get('A__C').name);
                    System.assertEquals('D', entity.referenceToMap.get('D').name);
                }
                when 'C' {
                    System.assertEquals(null, entity.total);
                    System.assertEquals(0, entity.fieldInitMap.keySet().size());
                    System.assertEquals(0, entity.fieldRuleMap.keySet().size());
                    System.assertEquals(0, entity.referenceToMap.keySet().size());
                }
                when else {
                }
            }
        }

        ATKWizard.Bag bag = new ATKWizard.Bag(spellBook);
        System.assertEquals(0, bag.get('A').size());

        Boolean isValid = true;
        try {
            ATKWizard.I().generate();
        } catch (Exception ex) {
            isValid = false;
        }
        System.assertEquals(false, isValid);
    }
}
