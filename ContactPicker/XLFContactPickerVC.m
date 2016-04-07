//
//  XLFContactPickerVC.m
//  ContactPicker
//
//
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "XLFContact.h"
#import "XLFContactPickerVC.h"
#import "XLFContactPickerCell.h"
#import "MBProgressHUDPrivate.h"
#import "ChineseToPinyin.h"

static NSArray *egContacts = nil;
@interface XLFContactPickerVC ()<ABPersonViewControllerDelegate>
@property (nonatomic, strong)UIBarButtonItem *barButton;
@property (nonatomic, strong)NSMutableArray *evSelectedContacts;
@property (nonatomic, strong)NSArray *evFilteredContacts;
@property (nonatomic, assign)ABAddressBookRef evAddressBookRef;
@property (nonatomic, strong)UILabel *evlbPrompt;

@end
@implementation XLFContactPickerVC
- (instancetype)init{
    
    self = [super init];
    if (self){

        if (!egContacts){
            egContacts = [NSArray array];
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setTitle:[NSString stringWithFormat:@"选择联系人%@",[self evMutableSelect] ? [NSString stringWithFormat:@" (0)"] : @""]];
    [[self tableView] setSeparatorColor:[UIColor clearColor]];
    [[self tableView] addSubview:[self evlbPrompt]];
    
    if ([self evMutableSelect]){

        [self setBarButton:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
        [[self barButton] setEnabled:FALSE];
        [[self navigationItem] setRightBarButtonItem:[self barButton]];
    }
    
    if (![egContacts count]){

        [MBProgressHUDPrivate showProgressWithStatus:@"加载中..." inView:[self view]];

        CFErrorRef error = nil;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, &error);

        __weak typeof(self)weakSelf = self;
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){

            [weakSelf setEvAddressBookRef:addressBookRef];

            if (granted){

                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf getContactsFromAddressBook];
                    [MBProgressHUDPrivate hideHUDForView:[weakSelf view] animated:YES];
                });
            }
            else {
                // TODO: Show alert
                [MBProgressHUDPrivate hideHUDForView:[weakSelf view] animated:NO];
                [weakSelf reloadData];
            }
        });
    }
    else{

        [self filterContacts];
        [self reloadData];
    }
}

- (UILabel*)evlbPrompt{

    if (nil == _evlbPrompt){

        _evlbPrompt = [[UILabel alloc] initWithFrame:[[self view] frame]];
        [_evlbPrompt setTextAlignment:NSTextAlignmentCenter];
        [_evlbPrompt setTextColor:[UIColor lightGrayColor]];
        [_evlbPrompt setText:@"没有联系人"];
        [_evlbPrompt setAlpha:0];
        [_evlbPrompt setUserInteractionEnabled:NO];
    }
    return _evlbPrompt;
}

- (void)reloadData{

    [[self tableView] reloadData];
    [[self tableView] setSeparatorColor:([[self evFilteredContacts] count] ? [UIColor grayColor] : [UIColor clearColor])];
    [[self evlbPrompt] setAlpha:([[self evFilteredContacts] count] ? 0 : 1 )];
}
- (void)getContactsFromAddressBook{
    
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook){

        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
      
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:[allContacts count]];
        
        NSUInteger i = 0;
        
        for (i = 0; i<[allContacts count]; i++){
    
    
            XLFContact *contact = [[XLFContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            [contact setRecordId:ABRecordGetRecordID(contactPerson)];
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            [contact setFirstName:firstName];
            [contact setLastName:lastName];
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            [contact setPhoneNums:[self getMobilePhoneProperty:phonesRef]];
            
            if(phonesRef){
    
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            [contact setImage:[UIImage imageWithData:imgData]];
            
            if (![contact image]){
    
                [contact setImage:[UIImage imageNamed:@"icon-avatar-60x60"]];
            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook){
    
            CFRelease(addressBook);
        }
    
        egContacts = [NSArray arrayWithArray:mutableContacts];
        
        
        [self filterContacts];
        
        [self reloadData];
    }
    else{
    
        NSLog(@"Error");
    }
}

- (void)filterContacts{

    [self setEvFilteredContacts:[egContacts sortedArrayUsingComparator:^NSComparisonResult(XLFContact *obj1, XLFContact *obj2){

        NSString *pinyin2 = [[obj2 fullName] pinyin];
        NSString *pinyin1 = [[obj1 fullName] pinyin];
        
        return [pinyin1 compare:pinyin2];
    }]];
    
    [[self evSelectedContacts] removeAllObjects];
}

- (void)refreshContacts{
    
    for (XLFContact* contact in egContacts){

        [self refreshContact: contact];
    }
}

- (void)refreshContact:(XLFContact*)contact{

    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID([self evAddressBookRef], (ABRecordID)[contact recordId]);
    [contact setRecordId:ABRecordGetRecordID(contactPerson)];
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    [contact setFirstName:firstName];
    [contact setLastName:lastName];
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    [contact setPhoneNums:[self getMobilePhoneProperty:phonesRef]];
    
    if(phonesRef){
    
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    [contact setImage:[UIImage imageWithData:imgData]];
    
    if (![contact image]){
    
        [contact setImage:[UIImage imageNamed:@"icon-avatar-60x60"]];
    }
}

- (NSArray *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef{

    NSMutableArray *phoneNums = [NSMutableArray array];
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++){
    
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
    
        if ( currentPhoneLabel && ( CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0)== kCFCompareEqualTo || CFStringCompare(currentPhoneLabel, kABHomeLabel, 0)== kCFCompareEqualTo)){

            [phoneNums addObject:(__bridge NSString *)currentPhoneValue];
        }
    
        if(currentPhoneLabel){
    
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue){
    
            CFRelease(currentPhoneValue);
        }
    }
    
    return phoneNums;
}
#pragma mark - UITableView Delegate and Datasource functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self evFilteredContacts] count];
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath {
    
    XLFContact *contact = [[self evFilteredContacts] objectAtIndex:[indexPath row]];
    
    return [XLFContactPickerCell epTableView:tableView heightWithModel:contact];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Get the desired contact from the filteredContacts array
    XLFContact *contact = [[self evFilteredContacts] objectAtIndex:[indexPath row]];
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    XLFContactPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
    
        cell = [[XLFContactPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setEvEnableCheck:[self evMutableSelect]];
    [cell setEvCheck:[[self evSelectedContacts] containsObject:contact]];
    [cell setEvModel:contact];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // This uses the custom cellView
    // Set the custom imageView
    XLFContact *contact = [[self evFilteredContacts] objectAtIndex:[indexPath row]];
    
    if ([self evMutableSelect]){

        XLFContactPickerCell *cell = (XLFContactPickerCell*)[tableView cellForRowAtIndexPath:indexPath];
        BOOL isContained = [[self evSelectedContacts] containsObject:contact];
        if (isContained){ // contact is already selected so remove it from ContactPickerView
            [[self evSelectedContacts] removeObject:contact];
        }
        else {
    
            [[self evSelectedContacts] addObject:contact];
        }
        
        // Enable Done button if total selected contacts > 0
        [[self barButton] setEnabled:[[self evSelectedContacts] count] > 0];
        
        // Update window title
        [self setTitle:[NSString stringWithFormat:@"选择联系人%@",[self evMutableSelect] ? [NSString stringWithFormat:@" (%lu)",(unsigned long)[[self evSelectedContacts] count]] : @""]];
        
        // Set check
        [cell setEvCheck:isContained];
    }
    else if ([self evDelegate] && [[self evDelegate] respondsToSelector:@selector(picker:contact:)]){
    
        [[self evDelegate] picker:self contact:contact];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;{

    XLFContact *contact = [[self evFilteredContacts] objectAtIndex:[indexPath row]];
    
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    [view setAddressBook:[self evAddressBookRef]];
    [view setPersonViewDelegate:self];
    [view setDisplayedPerson:ABAddressBookGetPersonWithRecordID([self evAddressBookRef], (ABRecordID)[contact recordId])];
    [view setAllowsEditing:NO];
    [view setAllowsActions:NO];
    [view setShouldShowLinkedPeople:NO];
    
    [[self navigationController] pushViewController:view animated:YES];
}
#pragma mark ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    return YES;
}
// TODO: send contact object
- (void)done:(id)sender{
    
    if ([self evDelegate] && [[self evDelegate] respondsToSelector:@selector(picker:contacts:)]){

        [[self evDelegate] picker:self contacts:[self evSelectedContacts]];
    }
}

@end
