# JSON schema guide

This is a reference for the JSON schema provided by Matrioska, which should be followed in order to register `Component`s and build the provided standard components.

## JSON schemas for `Component` and `ComponentMeta`

Below you can find a detailed schema for `Component`s and for each configuration (`ComponentMeta`).

### Main document schema

| Key | Type | Description | Optional |
| --- | ---- | ----------- | -------- |
| `structure` | `Component` | Root of the main `Component` structure representation. | No |

### Component schema

| Key | Type | Description | Optional |
| --- | ---- | ----------- | -------- |
| `type` | `String` | The type of the component. Used for factory registration. | No |
| `id` | `String` | A unique identifier for this `Component`. | Yes |
| `meta` | `Dictionary` | The additional metadata of the component. | Yes |
| `children` | `[Component]` | The children array of this `Component`. | Yes |
| `rule` | `Rule` | The `Rule` to apply to this `Component`. | Yes |

### Rule schema

A `Rule` can be composed by a simple rule type (`String`) or a logical operator combining multiple rule types.

| Operator | Description | Example |
| --------- | ------------ | ----------- |
| `AND` | AND operation on an array with at least two rule types. | `{"AND":["is_gold_member", {"NOT": "is_male"}]}` |
| `OR` | OR operation on an array with at least two rule types. | `{"OR":[{"NOT": "is_gold_member"}, "is_male", "has_devices"]}` |
| `NOT` | NOT operation on a rule type. | `{"NOT":"is_gold_member"}` |

### TabBarConfig meta schema

All mandatory fields should be present, otherwise the TabBar `Component` won't be build.

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `selected_index` | `Int` | The selected index of the tab bar. | `selectedIndex` | No | . |

### Tab meta schema

All mandatory fields should be present, otherwise the Tab `Component` won't be build and thus not added to the TabBar `Component`.

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `title` | `String` | The title to display on the tab. | `title` | No | . |
| `icon_name` | `Int` | The name of the icon to display on the tab. | `iconName` | No | . |

### StackConfig meta schema

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `title` | `String` | The title of the stack. | `title` | Yes | `nil` |
| `spacing` | `Float` | The spacing of the components inside the stack. | `spacing` | Yes | `10` |
| `orientation` | `String` | The orientation of the stack. Can be either `horizontal` or `vertical`. | `axis` | Yes | `vertical` |
| `preserve_parent_width` | `Bool` | Whether the arranged subviews should preserve the parent width or their own intrinsicContentSize. | `preserveParentWidth` | Yes | `false` |
| `background_color` | `String` | The background color of the stack. Alpha and compact forms are not supported. Valid formats: `0x123456` or `123456`. | `backgroundColor` | Yes | `ffffff`(white) |

## Example JSON

```
{
	"structure": {
		"type": "tabbar",
		"meta": {
			"selected_index": 1
		},
		"children": [{
			"type": "navigation",
			"rule":{
				"AND":[
					"is_gold_member",
					"is_male"
				]
			},
			"meta": {
				"title": "history_title",
				"icon_name": "history_tab_icon"
			},
			"children": [{
				"type": "stack",
				"meta": {
					"orientation": "vertical",
					"preserve_parent_width": true,
					"background_color": "0x123456"
				},
				"rule": "is_male",
				"children": [{
					"type": "table_view",
					"rule":{
						"OR":[
							"is_gold_member",
							{
								"NOT":"is_male"
							}
						]
					}
				}]
			}]
		}, {
			"type": "navigation",
			"meta": {
				"title": "main_tab_title",
				"icon_name": "main_tab_icon"
			},
			"rule": "is_gold_member",
			"children": [{
				"type": "stack",
				"meta": {
					"orientation": "vertical",
					"title": "Main stack",
					"preserve_parent_width": true,
					"spacing": "5"
				},
				"rule":{
					"NOT":"is_male"
				},
				"children": [{
					"type": "label",
					"meta": {
					}
				}, {
					"type": "test_feature",
					"meta": {
					},
					"rule":{
						"NOT":"is_gold_member"
					}
				}
			]
			}]
		}]
	}
}
```
