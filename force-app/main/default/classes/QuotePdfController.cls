public with sharing class QuotePdfController {
    public Quote quote { get; set; }
    public Map<Id, String> productImages { get; set; }

    public QuotePdfController() {
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        if (quoteId != null) {
            quote = [SELECT Id, Name, QuoteNumber FROM Quote WHERE Id = :quoteId LIMIT 1];
            initializeProductImages();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Quote ID.'));
        }
    }

    public QuotePdfController(ApexPages.StandardController controller) {
        quote = (Quote)controller.getRecord();
        if (quote.Id != null) {
            initializeProductImages();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Quote ID.'));
        }
    }

     // image라는 보장? // need dft img
    private void initializeProductImages() {
        productImages = new Map<Id, String>();
        
        List<QuoteLineItem> lineItems = [
            SELECT Product2Id 
            FROM QuoteLineItem 
            WHERE QuoteId = :quote.Id
        ];

        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem item : lineItems) {
            if (item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
        }

        for (Id productId : productIds) {
            productImages.put(productId, ''); // need dft img
        }

        if (!productIds.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :productIds
            ];

            for (ContentDocumentLink link : contentDocumentLinks) {
                ContentVersion contentVersion = [
                    SELECT Id, ContentDocumentId 
                    FROM ContentVersion 
                    WHERE ContentDocumentId = :link.ContentDocumentId 
                    ORDER BY VersionNumber DESC 
                    LIMIT 1
                ];
                productImages.put(link.LinkedEntityId, '/sfc/servlet.shepherd/version/download/' + contentVersion.Id);
            }
        }
    }

    public PageReference savePdf() {
        PageReference pdfPage = Page.QuotePdfContent; 
        pdfPage.getParameters().put('id', quote.Id);
        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'blob gen size: ' + pdfBlob.size()));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error generating PDF: ' + e.getMessage()));
            return null;
        }
        
        try {
            QuoteDocument quoteDoc = new QuoteDocument();
            quoteDoc.QuoteId = quote.Id;
            quoteDoc.Document = pdfBlob;
            insert quoteDoc;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PDF has been saved successfully.'));

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving PDF: ' + e.getMessage()));
            return null;
        }
        
        return redir();
    }

    public PageReference redir() {
        String lightningUrl = '/lightning/r/Quote/' + quote.Id + '/view';
        PageReference redirectPage = new PageReference(lightningUrl);
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    public void emailPdf() {
        savePdf();
        // 다음동작이 되나?
    }
}