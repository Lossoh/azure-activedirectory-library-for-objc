// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ADRequestParameters.h"
#import "ADUserIdentifier.h"
#import "MSIDConfiguration.h"
#import "MSIDAccountIdentifier.h"
#import "NSString+MSIDExtensions.h"
#import "MSIDAuthorityFactory.h"

@implementation ADRequestParameters

- (id)copyWithZone:(NSZone*)zone
{
    ADRequestParameters *parameters = [[ADRequestParameters allocWithZone:zone] init];
    
    parameters->_authority = [_authority copyWithZone:zone];
    parameters->_cloudAuthority = [_cloudAuthority copyWithZone:zone];
    parameters->_resource = [_resource copyWithZone:zone];
    parameters->_clientId = [_clientId copyWithZone:zone];
    parameters->_redirectUri = [_redirectUri copyWithZone:zone];
    parameters->_scopesString = [_scopesString copyWithZone:zone];
    parameters->_identifier = [_identifier copyWithZone:zone];
    parameters->_claims = [_claims copyWithZone:zone];
    parameters->_extraQueryParameters = [_extraQueryParameters copyWithZone:zone];
    parameters->_extendedLifetime = _extendedLifetime;
    parameters->_forceRefresh = _forceRefresh;
    parameters->_correlationId = [_correlationId copyWithZone:zone];
    parameters->_telemetryRequestId = [_telemetryRequestId copyWithZone:zone];
    parameters->_logComponent = [_logComponent copyWithZone:zone];
    parameters->_account = [_account copyWithZone:zone];
    
    return parameters;
}

- (void)setResource:(NSString *)resource
{
    _resource = [resource msidTrimmedString];
}

- (void)setClientId:(NSString *)clientId
{
    _clientId = [clientId msidTrimmedString];
}

- (void)setRedirectUri:(NSString *)redirectUri
{
    _redirectUri = [redirectUri msidTrimmedString];
}

- (void)setScopesString:(NSString *)scopesString
{
    _scopesString = scopesString;
}

- (NSString *)openIdScopesString
{
    if (!self.scopesString)
    {
        return @"openid";
    }

    NSOrderedSet<NSString *> *scopes = [self.scopesString msidScopeSet];
    if (![scopes containsObject:@"openid"])
    {
        return [NSString stringWithFormat:@"openid %@", self.scopesString];
    }

    return self.scopesString;
}

- (void)setIdentifier:(ADUserIdentifier *)identifier
{
    _identifier = identifier;
    
    self.account = [[MSIDAccountIdentifier alloc] initWithLegacyAccountId:self.identifier.userId
                                                            homeAccountId:nil];
}

- (MSIDConfiguration *)msidConfig
{
    NSURL *authorityUrl = [[NSURL alloc] initWithString:self.cloudAuthority ? self.cloudAuthority : self.authority];
    __auto_type factory = [MSIDAuthorityFactory new];
    __auto_type authority = [factory authorityFromUrl:authorityUrl context:nil error:nil];
    
    MSIDConfiguration *config = [[MSIDConfiguration alloc] initWithAuthority:authority
                                                                 redirectUri:self.redirectUri
                                                                    clientId:self.clientId
                                                                      target:self.resource];
    
    return config;
}

@end
