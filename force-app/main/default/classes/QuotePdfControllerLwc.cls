public with sharing class QuotePdfControllerLwc {
    @AuraEnabled
    public static String getQuotePdf(Id quoteId) {
        PageReference pdfPage = Page.QuotePdfContent; // Ensure this Visualforce page exists
        pdfPage.getParameters().put('id', quoteId);
        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            return null;
        }
        
        try {
            QuoteDocument quoteDoc = new QuoteDocument();
            quoteDoc.QuoteId = quoteId;
            quoteDoc.Document = pdfBlob;
            insert quoteDoc;
        } catch (Exception e) {
            return null;
        }
        
        return 'hello'; // cannot return pageref at auraenabled. refresh 뭐였지?

        // 에러 핸들링
    }
}
